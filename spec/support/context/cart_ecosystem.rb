RSpec.shared_context "cart ecosystem" do
  module Spec
    class Cart < ActiveRecord::Base
      self.table_name = :carts

      serialize :metadata, JSON

      scope :completed, -> { where(status: :completed) }

      has_many :items, class_name: Spec::Item

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

    class CartShadow < ActiveRecord::Shadow::Member

      shadow Spec::Cart

      related :consumer, Spec::ConsumerShadow
      related :items, Spec::ItemsShadow

      static :discount_cents
      computed :subtotal_cents
      computed :subdiscount_cents
      computed :shipping_cents
      computed :tax_cents
      computed :total_cents

    end

    class CartsShadow < Activerecord::Shadow::Collection

      filter :default, Spec::CartShadow
      filter :completed, Spec::CartShadow
    end
  end

  let(:_cart_class) do
    Spec::Cart
  end

  let(:_cart_shadow_class) do
    Spec::CartShadow
  end

  let(:_carts_shadow_class) do
    Spec::CartsShadow
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

  before(:each) do
    ActiveRecord::Migration.create_table(:carts, force: true) do |table|
      table.integer :discount_cents, default: 0, null: false
      table.string :state, null: false
      table.string :status, null: false, default: :started
      table.integer :consumer_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end
end
