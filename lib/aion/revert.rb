module Aion
  class Revert
    def initialize(changeset, delete_changeset:)
      @changeset = changeset
      @delete_changeset = delete_changeset
      @versionable = changeset.versionable
    end

    def execute
      ActiveRecord::Base.transaction do
        changesets_to_delete.each do |current_changeset|
          revert_changeset(versionable, current_changeset)
          current_changeset.destroy!
        end
      end
    end

    private

    attr_reader :changeset, :delete_changeset, :versionable

    def changesets_to_delete
      filter_by_version(changesets_scope).order(version: :desc)
    end

    def changesets_scope
      Changeset.where(
        versionable_type: versionable.class.name,
        versionable_identifier: versionable.public_send(versionable.class.aion_options[:identifier]),
        locale: changeset.locale
      )
    end

    def filter_by_version(scope)
      if delete_changeset
        scope.where('version >= ?', changeset.version)
      else
        scope.where('version > ?', changeset.version)
      end
    end

    # Format of the values in the diff field is:
    # {"attribute" : ["old_value", "new_value"]}
    def revert_changeset(record, changeset_to_revert)
      I18n.with_locale(changeset_to_revert.locale) do
        changeset_to_revert.diff.each do |attribute, values|
          record.public_send "#{attribute}=", values[0]
        end

        record.skip_aion_versioning = true
        record.save!
        record.skip_aion_versioning = false
      end
    end
  end
end
