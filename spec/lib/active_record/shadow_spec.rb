require "spec_helper"

RSpec.describe(ActiveRecord::Shadow) do
  include_context "cart ecosystem"
  include_context "consumer ecosystem"
  include_context "item ecosystem"

  describe "modifying a deep object value" do
    let(:shadow) do
      _cart_shadow_class.new(_cart)
    end

    before(:each) do
      _cart.save
    end

    context "when setting a static property" do
      it "doesn't modify original" do
        expect do
          shadow.consumer.credit_cents = 100_00
        end.to_not change(_consumer, :credit_cents).from(0)
      end

      it "modifies the shadow" do
        expect do
          shadow.consumer.credit_cents = 100_00
        end.to change(shadow.consumer, :credit_cents).from(0).to(100_00)
      end

      it "changes the result of a computed property" do
        expect do
          binding.pry
          shadow.items.premium.first.discount_cents = 10_00
        end.to change(shadow, :total_cents).from(127_40).to(117_40)
      end
    end
  end
end
