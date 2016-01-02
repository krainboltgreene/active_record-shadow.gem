RSpec.shared_context "consumer ecosystem" do
  let(:_consumer_class) do
    Class.new(ActiveRecord::Base) do

      self.table_name = :consumers

      has_many :carts, class_name: _cart_class
    end
  end

  let(:_consumer_attributes) do
    {
      email: "casper@example.com",
      carts: _carts
    }
  end

  let(:_consumer) do
    _consumer_class.new(_consumer_attributes)
  end

  let(:_consumer_shadow_class) do
    Class.new(ActiveRecord::Shadow::Member) do

      shadow _consumer_class

      related :carts, _carts_shadow_class

      static :credit_cents
      ignore :email

    end
  end

  before(:each) do
    ActiveRecord::Migration.create_table(:consumers, id: :uuid, force: true) do |table|
      table.string :email, default: 0, null: false
      table.integer :credit_cents, default: 0, null: false
      table.json :metadata, default: "{}"
      table.timestamps
    end
  end
end
