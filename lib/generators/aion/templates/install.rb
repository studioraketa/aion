class <%= migration_class_name %> < <%= migration_base_class %>
  def up
    create_table :aion_changesets do |t|
      t.string :versionable_type, null: false
      t.string :versionable_identifier, limit: 50, null: false
      t.string :locale, limit: 20, null: false
      t.string :operator, null: false
      t.string :action, limit: 20, null: false
      t.json :diff, null: false, default: {}
      t.integer :version, null: false
      t.string :request_uuid, null: false, default: ''
      t.datetime :created_at, null: false
      t.boolean :archived, null: false, default: false
    end

    add_index :aion_changesets, :created_at
    add_index :aion_changesets, :locale
    add_index :aion_changesets, :archived
    add_index(
      :aion_changesets,
      %i[versionable_type versionable_identifier version locale],
      unique: true,
      name: 'aion_changesets_versionable_localized_index'
    )
    add_index(
      :aion_changesets,
      %i[versionable_type versionable_identifier],
      name: 'aion_changesets_versionable_index'
    )
  end

  def down
    drop_table :aion_changesets
  end
end
