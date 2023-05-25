ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.string :username, null: false, default: ''
    t.string :password, null: false, default: ''
    t.boolean :activated, null: false, default: false
    t.integer :status, default: 0, null: false
    t.datetime :activated_at
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
  end

  add_index :users, :username, unique: true

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

def truncate_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
  end
end

class User < ActiveRecord::Base
  aion_track_changes

  enum status: { guest: 0, moderator: 1, admin: 2 }
end

class UserOnlyUserName < ActiveRecord::Base
  self.table_name = 'users'

  aion_track_changes only: :username

  enum status: { guest: 0, moderator: 1, admin: 2 }
end

class UserExceptPassword < ActiveRecord::Base
  self.table_name = 'users'

  aion_track_changes except: :password

  enum status: { guest: 0, moderator: 1, admin: 2 }
end

class UserWithCustomIdentifier < ActiveRecord::Base
  self.table_name = 'users'

  aion_track_changes identifier: :username

  enum status: { guest: 0, moderator: 1, admin: 2 }
end

class UntrackedUser < ActiveRecord::Base
  self.table_name = 'users'

  enum status: { guest: 0, moderator: 1, admin: 2 }
end
