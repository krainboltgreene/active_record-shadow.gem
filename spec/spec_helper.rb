require "codeclimate-test-reporter"
require "pry"
require "rspec"
require "active_record-shadow"

require_relative "support/active_model/validations"
require_relative "support/context/cart_ecosystem"
require_relative "support/context/consumer_ecosystem"
require_relative "support/context/item_ecosystem"

RSpec.configure do |let|
  let.before("suite") do
    CodeClimate::TestReporter.start
  end

  let.before(:suite) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
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
