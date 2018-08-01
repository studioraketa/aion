# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.column :username, :string
    t.column :password, :string
    t.column :activated, :boolean
    t.column :status, :integer, default: 0
    t.column :suspended_at, :datetime
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :aion_changesets do |t|
    t.string :versionable_type, null: false
    t.string :versionable_identifier, limit: 20, null: false
    t.string :locale, limit: 20, null: false
    t.string :operator, null: false
    t.string :action, limit: 20, null: false
    t.json :diff, null: false, default: {}
    t.integer :version, null: false
    t.string :request_uuid, null: false, default: ''
    t.datetime :created_at, null: false
  end

  add_index :aion_changesets, :created_at
  add_index :aion_changesets, :locale
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
