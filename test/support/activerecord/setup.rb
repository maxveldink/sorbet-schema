# typed: false
# frozen_string_literal: true

require "active_record"
require "active_record/database_configurations"

test_dir = Pathname.new(File.dirname(__FILE__)).join("../..")
yaml_config = YAML.safe_load_file(test_dir.join("support/activerecord/database.yml"), aliases: true)
config = ActiveRecord::DatabaseConfigurations::HashConfig.new("test", "sqlite3", yaml_config)
ActiveRecord::Base.configurations.configurations << config
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Schema.define do
  create_table :countries, force: :cascade do |t|
    t.string :name
  end

  create_table :locations, force: :cascade do |t|
    t.string :name
    t.integer :country_id
  end

  create_table :users, force: :cascade do |t|
    t.string :name
    t.integer :age
    t.integer :location_id
  end

  create_table :posts, force: :cascade do |t|
    t.string :title
    t.string :status
  end

  create_table :simple_pets, force: :cascade do |t|
    t.string :breed
  end

  create_table :complex_pets, force: :cascade do |t|
    t.string :name
    t.string :breed
    t.integer :age
    t.boolean :pedigree
  end
end
