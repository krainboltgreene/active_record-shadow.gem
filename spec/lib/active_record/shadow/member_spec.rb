require "spec_helper"

RSpec.describe(ActiveRecord::Shadow::Member) do
  let(:member) { stub_const("Member", described_class) }

  describe ".static" do
    let(:key) { "test" }
    let(:static) { member.static(key) }

    before(:each) do
      allow(member).to receive(:statics).and_return(statics)
    end

    context "with no other statics defined" do
      let(:statics) { Set.new }

      it "returns the key in the list" do
        expect(static).to include(key)
      end
    end

    context "with some statics defined" do
      let(:statics) { Set["a", "b", "c"] }

      context "with a nonunique key" do
        let(:key) { "a" }

        it "doesn't contain key twice" do
          expect(statics).to eq(statics)
        end

        it "returns the key" do
          expect(statics).to include(key)
        end

        it "returns the previous keys" do
          expect(statics).to include(*statics)
        end
      end

      context "with a unique key" do
        let(:key) { "d" }

        it "returns the key" do
          expect(static).to include(key)
        end

        it "returns the previous keys" do
          expect(static).to include(*statics)
        end
      end
    end
  end

  describe ".computed" do
    let(:key) { "test" }
    let(:computed) { member.computed(key) }

    before(:each) do
      allow(member).to receive(:computeds).and_return(computeds)
    end

    context "with no other computeds defined" do
      let(:computeds) { Set.new }

      it "returns the key in the list" do
        expect(computed).to include(key)
      end
    end

    context "with some computeds defined" do
      let(:computeds) { Set["a", "b", "c"] }

      context "with a nonunique key" do
        let(:key) { "a" }

        it "doesn't contain key twice" do
          expect(computeds).to eq(computeds)
        end

        it "returns the key" do
          expect(computeds).to include(key)
        end

        it "returns the previous keys" do
          expect(computeds).to include(*computeds)
        end
      end

      context "with a unique key" do
        let(:key) { "d" }

        it "returns the key" do
          expect(computed).to include(key)
        end

        it "returns the previous keys" do
          expect(computed).to include(*computeds)
        end
      end
    end
  end

  describe ".ignore" do
    let(:key) { "test" }
    let(:ignore) { member.ignore(key) }

    before(:each) do
      allow(member).to receive(:ignores).and_return(ignores)
    end

    context "with no other ignores defined" do
      let(:ignores) { Set.new }

      it "returns the key in the list" do
        expect(ignore).to include(key)
      end
    end

    context "with some ignores defined" do
      let(:ignores) { Set["a", "b", "c"] }

      context "with a nonunique key" do
        let(:key) { "a" }

        it "doesn't contain key twice" do
          expect(ignores).to eq(ignores)
        end

        it "returns the key" do
          expect(ignores).to include(key)
        end

        it "returns the previous keys" do
          expect(ignores).to include(*ignores)
        end
      end

      context "with a unique key" do
        let(:key) { "d" }

        it "returns the key" do
          expect(ignore).to include(key)
        end

        it "returns the previous keys" do
          expect(ignore).to include(*ignores)
        end
      end
    end
  end
end
