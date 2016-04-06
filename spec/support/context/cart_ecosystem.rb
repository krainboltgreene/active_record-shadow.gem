RSpec.shared_context "cart ecosystem" do
  module Spec
    class Cart < ActiveRecord::Base
      TAX = 0.02
      SHIPPING = {
        "Nowhere" => 5_00
      }

      self.table_name = :carts

      serialize :metadata, JSON

      scope :completed, -> { where(status: :completed) }

      has_many :items, class_name: Spec::Item
      belongs_to :consumer, class_name: Spec::Consumer

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

      related :consumer, Spec::ConsumerShadow
      related :items, Spec::ItemsShadow

      static :discount_cents

      computed :subtotal_cents
      computed :subdiscount_cents
      computed :shipping_cents
      computed :tax_cents
      computed :total_cents

    end

    class CartsShadow < ActiveRecord::Shadow::Collection

      shadow Spec::CartShadow

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
      state: "Nowhere"
    }
  end

  let(:_cart) do
    _cart_class.new(_cart_attributes)
  end

  let(:_carts) do
    [_cart]
  end

  before(:each) do
    _cart.consumer = _consumer
    _cart.items = _items
  end
end
