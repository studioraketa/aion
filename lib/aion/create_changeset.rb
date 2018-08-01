module Aion
  class CreateChangeset
    def initialize(record, options)
      @record = record
      @options = options
    end

    def execute
      diff = calculate_diff

      return if diff.empty?

      Changeset.create!(
        {
          versionable_type: versionable_type,
          versionable_identifier: versionable_identifier,
          locale: locale,
          action: options[:action],
          diff: diff,
          version: version
        }.merge(normalized_controller_statistics)
      )
    end

    private

    attr_reader :record, :options

    def normalized_controller_statistics
      options[:controller_statistics].each_with_object({}) do |attribute, memo|
        memo[attribute] = store.fetch(attribute, '')
      end
    end

    def version
      current_version + 1
    end

    def current_version
      Changeset.where(
        versionable_type: versionable_type,
        versionable_identifier: versionable_identifier,
        locale: locale
      ).maximum(:version) || 0
    end

    def calculate_diff
      Diff.new(
        record,
        options.slice(:changes_extractor, :action, :locale)
      ).calculate
    end

    def versionable_type
      record.class.name
    end

    def versionable_identifier
      record.public_send record.class.aion_options[:identifier]
    end

    def store
      options[:store]
    end

    def locale
      options[:locale]
    end
  end
end
