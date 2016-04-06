RSpec.shared_context "consumer ecosystem" do

  module Spec
    class Consumer < ActiveRecord::Base
      self.table_name = :consumers

      serialize :metadata, JSON

      has_many :carts, class_name: Spec::Cart
    end

    class ConsumerShadow < ActiveRecord::Shadow::Member

      related :carts, Spec::CartsShadow

      static :metadata
      static :credit_cents

      ignore :email

    end
  end

  let(:_consumer_class) do
    Spec::Consumer
  end

  let(:_consumer_shadow_class) do
    Spec::ConsumerShadow
  end

  let(:_consumer_attributes) do
    {
      email: "casper@example.com"
    }
  end

  let(:_consumer) do
    _consumer_class.new(_consumer_attributes)
  end

  before(:each) do
    _consumer.carts = _carts
  end
end
