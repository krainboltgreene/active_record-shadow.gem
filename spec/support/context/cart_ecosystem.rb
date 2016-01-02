RSpec.shared_context "cart ecosystem" do
  let(:_cart_class) do
    Class.new(ActiveRecord::Base) do
      TAX = 0.10
      SHIPPING = {
        "Nowhere" => 5_00
      }

      self.table_name = :carts

      scope :completed, -> { where(status: :completed) }

      has_many :items, class_name: _item_class

      def tax_cents
        subtotal_cents * TAX
      end

      def shipping_cents
        SHIPPING[state]
      end

      def subtotal_cents
        items.sum(:subtotal_cents)
      end

      def subdiscount_cents
        items.sum(:discount_cents)
      end

      def total_cents
        (subtotal_cents - subdiscount_cents - discount_cents) + tax_cents + shipping_cents
      end
    end
  end


  let(:_cart_attributes) do
    {
      state: "Nowhere",
      consumer: _consumer,
      items: _items
    }
  end

  let(:_cart) do
    _cart_class.new(_cart_attributes)
  end

  let(:_cart_shadow_class) do
    Class.new(ActiveRecord::Shadow::Member) do

      shadow _cart_class

      related :consumer, _consumer_shadow_class
      related :items, _items_shadow_class

      static :discount_cents
      dynamic :subtotal_cents
      dynamic :subdiscount_cents
      dynamic :shipping_cents
      dynamic :tax_cents
      dynamic :total_cents

    end
  end

  let(:_carts_shadow_class) do
    Class.new(ActiveRecord::Shadow::Collection) do

      filter :default, _cart_shadow_class
      filter :completed, _cart_shadow_class

    end
  end

  before(:each) do
    ActiveRecord::Migration.create_table(:carts, id: :uuid, force: true) do |table|
      table.integer :discount_cents, default: 0, null: false
      table.string :state, null: false
      table.string :status, null: false, default: :started
      table.uuid :consumer_id, null: false
      table.json :metadata, default: "{}"
      table.timestamps
    end
  end
end
