require "codeclimate-test-reporter"
require "pry"
require "rspec"
require "active_record-shadow"

require_relative "support/eager"
require_relative "support/active_model/validations"
require_relative "support/context/cart_ecosystem"
require_relative "support/context/consumer_ecosystem"
require_relative "support/context/item_ecosystem"

RSpec.configure do |let|
  let.before(:suite) do
    CodeClimate::TestReporter.start
  end

  let.before(:suite) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
  end

  let.before(:each) do
    ActiveRecord::Migration.create_table(:items, force: true) do |table|
      table.integer :subtotal_cents, default: 0, null: false
      table.integer :discount_cents, default: 0, null: false
      table.integer :cart_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.before(:each) do
    ActiveRecord::Migration.create_table(:carts, force: true) do |table|
      table.integer :discount_cents, default: 0, null: false
      table.string :state, null: false
      table.string :status, null: false, default: :started
      table.integer :consumer_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.before(:each) do
    ActiveRecord::Migration.create_table(:consumers, force: true) do |table|
      table.string :email, default: 0, null: false
      table.integer :credit_cents, default: 0, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end

  let.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  # Exit the spec after the first failure
  let.fail_fast = true

  # Only run a specific file, using the ENV variable
  # Example: FILE=spec/active_record/shadow/version_spec.rb bundle exec rake spec
  let.pattern = ENV["FILE"]

  # Show the slowest examples in the suite
  let.profile_examples = true

  # Colorize the output
  let.color = true

  # Output as a document string
  let.default_formatter = "doc"
end
