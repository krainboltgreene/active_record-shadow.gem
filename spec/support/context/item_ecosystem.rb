RSpec.shared_context "item ecosystem" do
  let(:_item_class) do
    Class.new(ActiveRecord::Base) do

      self.table_name = :items

      belongs_to :cart, class_name: _cart_class

      def total_cents
        subtotal_cents + discount_cents
      end
    end
  end

  let(:_item_attributes) do
    {
      subtotal_cents: 20_00,
      cart: _cart
    }
  end

  let(:_item) do
    _item_class.new(_item_attributes)
  end

  let(:_item_shadow_class) do
    Class.new(ActiveRecord::Shadow::Member) do

      shadow _item_class

      related :cart, _cart_shadow_class

      static :subtotal_cents
      static :discount_cents
      dynamic :total_cents
    end
  end


  before(:each) do
    ActiveRecord::Migration.create_table(:items, id: :uuid, force: true) do |table|
      table.integer :subtotal_cents, default: 0, null: false
      table.integer :discount_cents, default: 0, null: false
      table.uuid :cart_id, null: false
      table.json :metadata, default: "{}"
      table.timestamps
    end
  end
end
