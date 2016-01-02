RSpec.shared_context "item ecosystem" do

  module Spec
    class Item < ActiveRecord::Base

      self.table_name = :items

      serialize :metadata, JSON

      belongs_to :cart, class_name: Spec::Cart

      def total_cents
        subtotal_cents + discount_cents
      end
    end

    class ItemShadow < ActiveRecord::Shadow::Member
      shadow Spec::Item

      related :cart, Spec::CartShadow

      static :subtotal_cents
      static :discount_cents
      computed :total_cents
    end

    class ItemsShadow < ActiveRecord::Shadow::Collection
      filter :default, Spec::ItemShadow
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
      subtotal_cents: 20_00,
      cart: _cart
    }
  end

  let(:_item) do
    _item_class.new(_item_attributes)
  end

  before(:each) do
    ActiveRecord::Migration.create_table(:items, force: true) do |table|
      table.integer :subtotal_cents, default: 0, null: false
      table.integer :discount_cents, default: 0, null: false
      table.integer :cart_id, null: false
      table.text :metadata, default: "{}"
      table.timestamps null: false
    end
  end
end
