module Aion
  class RecordChanges
    class << self
      def extractor(custom_changes_class = nil)
        return custom_changes_class if custom_changes_class

        Default
      end
    end

    class Default
      def initialize(record, _locale)
        @record = record
      end

      def extract
        @record.changes
      end
    end
  end
end
