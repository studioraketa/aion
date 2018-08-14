module Aion
  class Changeset < ::ActiveRecord::Base
    self.table_name = 'aion_changesets'

    scope :active, ->{ where(archived: false) }
    scope :inactive, ->{ where(archived: true) }
    scope :for_locale, ->(locale) { where(locale: locale) }
    scope :after, ->(datetime) { where('created_at > ?', datetime) }
    scope :before, ->(datetime) { where('created_at < ?', datetime) }

    def versionable
      @versionable ||= versionable_class.find_by(
        versionable_class.aion_options[:identifier] => versionable_identifier
      )
    end

    def reload
      @versionable = nil

      super
    end

    def revertable?
      version > 1 && action != 'destroy'
    end

    def revert
      raise IrreversibleChangeError unless revertable?

      Revert.new(self, delete_changeset: true).execute
    end

    def revert_to
      Revert.new(self, delete_changeset: false).execute
    end

    private

    def versionable_class
      versionable_type.constantize
    end
  end
end
