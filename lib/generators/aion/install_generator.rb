module Aion
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    class << self
      def next_migration_number(dirname)
        number = current_migration_number(dirname) + 1

        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % number].max
        else
          SchemaMigration.normalize_migration_number(number)
        end
      end
    end

    source_root File.expand_path("../templates", __FILE__)

    def copy_migration
      migration_template "install.rb", "db/migrate/install_aion.rb"
    end

    def migration_base_class
      "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
    end
  end
end
