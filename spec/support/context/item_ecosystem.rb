RSpec.shared_context "item ecosystem" do

  module Spec
    class Item < ActiveRecord::Base

      self.table_name = :items

      serialize :metadata, JSON

      belongs_to :cart, class_name: Spec::Cart

      scope :premium, -> { where(subtotal_cents: 100_00) }

      def total_cents
        subtotal_cents + discount_cents
      end

    end

    class ItemShadow < ActiveRecord::Shadow::Member

      related :cart, Spec::CartShadow

      static :subtotal_cents
      static :discount_cents

      computed :total_cents

    end

    class ItemsShadow < ActiveRecord::Shadow::Collection

      shadow Spec::ItemShadow

      filter :premium, Spec::ItemShadow

    end
  end

  let(:_item_class) do
    Spec::Item
  end

  let(:_item_shadow_class) do
    Spec::ItemShadow
  end

  let(:_items_shadow_class) do
    Spec::ItemsShadow
  end

  let(:_item_attributes) do
    {
      subtotal_cents: 20_00
    }
  end

  let(:_item_premium_attributes) do
    {
      subtotal_cents: 100_00
    }
  end

  let(:_item) do
    _item_class.new(_item_attributes)
  end

  let(:_item_premium) do
    _item_class.new(_item_premium_attributes)
  end

  let(:_items) do
    [_item, _item_premium]
  end

  before(:each) do
    _item.cart = _cart
  end
end
