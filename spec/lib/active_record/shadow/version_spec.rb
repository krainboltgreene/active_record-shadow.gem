require "spec_helper"

RSpec.describe(ActiveRecord::Shadow::VERSION) do
  it "should be a string" do
    expect(ActiveRecord::Shadow::VERSION).to be_kind_of(String)
  end
end
