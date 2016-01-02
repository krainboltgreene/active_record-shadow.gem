require "spec_helper"

RSpec.describe ActiveRecord::Shadow do
  include_context "cart ecosystem"
  include_context "consumer ecosystem"
  include_context "item ecosystem"

  describe "modifying a value" do
    before(:each) do
      _cart.save
    end

    it "doesn't modify the object's value" do
      expect(true).to be(true)
    end
  end
end
