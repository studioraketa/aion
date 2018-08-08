module Aion
  module Tracking
    extend ActiveSupport::Concern

    module ClassMethods
      def aion_track_changes(options = {})
        return if included_modules.include?(Tracking::TrackingInstanceMethods)

        extend Tracking::TrackingClassMethods
        include Tracking::TrackingInstanceMethods

        class_attribute :aion_options, instance_accessor: false

        self.aion_options = normalize_aion_options(options)

        after_create :aion_create
        before_update :aion_update
        before_destroy :aion_destroy
      end
    end

    module TrackingInstanceMethods
      def without_tracking
        @skip_aion_versioning = true

        yield self
      ensure
        @skip_aion_versioning = false
      end

      def aion_create
        write_version 'create'
      end

      def aion_update
        write_version 'update'
      end

      def aion_destroy
        write_version('destroy') unless new_record?
      end

      def write_version(action)
        return if skip_aion_versioning?

        CreateChangeset.new(self, aion_options.merge(action: action)).execute
      end

      def aion_options
        {
          locale: I18n.locale,
          controller_statistics: Aion.controller_statistics,
          store: Aion.request_store,
          request_uuid: Aion.request_store[:request_uuid].presence || '',
          changes_extractor: RecordChanges.extractor(self.class.aion_options[:custom_changes_class])
        }
      end

      def versions
        Changeset.where(
          versionable_type: self.class.name,
          versionable_identifier: self.public_send(self.class.aion_options[:identifier])
        ).order(id: :asc, version: :asc)
      end

      private

      def skip_aion_versioning?
        @skip_aion_versioning || false
      end
    end

    module TrackingClassMethods
      def normalize_aion_options(input)
        Hash.new.tap do |hash|
          hash[:only] = Array(input[:only]).map(&:to_s)
          hash[:except] = Array(input[:except]).map(&:to_s)
          hash[:custom_changes_class] = input[:custom_changes_class]
          hash[:identifier] = input[:identifier].presence || :id
        end
      end
    end
  end
end
