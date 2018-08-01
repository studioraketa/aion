module Aion
  class Diff
    IGNORED_ATTRIBUTES = %w[created_at updated_at].freeze

    def initialize(record, options)
      @record = record
      @action = options.fetch(:action)
      @locale = options.fetch(:locale)
      @changes_extractor = options.fetch(:changes_extractor)
    end

    def calculate
      case action
        when 'update' then calculate_changes_on_update
        when 'create' then calculate_changes_om_create
        when 'destroy' then calculate_changes_on_destroy
      end
    end

    private

    attr_reader :record, :action, :changes_extractor, :locale

    def calculate_changes_om_create
      record.attributes.except(*not_logged_columns).each_with_object({}) do |key_value, memo|
        key, value = key_value
        memo[key] = [nil, value]
      end
    end

    def calculate_changes_on_destroy
      record.attributes.except(*not_logged_columns).each_with_object({}) do |key_value, memo|
        key, value = key_value
        memo[key] = [value, nil]
      end
    end

    def calculate_changes_on_update
      if aion_options[:only].present?
        all_changes.slice(*logged_columns)
      else
        all_changes.except(*not_logged_columns)
      end
    end

    def all_changes
      changes_extractor.new(record, locale).extract
    end

    def logged_columns
      record.class.column_names - not_logged_columns
    end

    def not_logged_columns
      if aion_options[:only].present?
        (record.class.column_names | default_ignored_columns) - aion_options[:only]
      elsif aion_options[:except].present?
        default_ignored_columns | aion_options[:except]
      else
        default_ignored_columns
      end
    end

    def aion_options
      record.class.aion_options
    end

    def default_ignored_columns
      [record.class.primary_key, record.class.inheritance_column] | IGNORED_ATTRIBUTES
    end
  end
end
