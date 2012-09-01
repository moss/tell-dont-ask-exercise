require 'life'
require 'spec_helper'

describe PopulationDensity do
  subject { PopulationDensity.new }

  def expect_generates_life expected_liveliness
    lively = false
    subject.if_generates_life { lively = true }
    expect { lively == expected_liveliness }
  end

  def expect_supports_life expected_liveliness
    lively = false
    subject.if_supports_life { lively = true }
    expect { lively == expected_liveliness }
  end

  context "with one neighbor" do
    before { subject.increment }
    it("does not generate life") { expect_generates_life false }
    it("does not support life") { expect_supports_life false }
  end

  context "with two neighbors" do
    before { subject.increment.increment }
    it("does not generate life") { expect_generates_life false }
    it("supports life") { expect_supports_life true }
  end

  context "with three neighbors" do
    before { subject.increment.increment.increment }
    it("generates life") { expect_generates_life true }
    it("supports life") { expect_supports_life true }
  end

  context "with four neighbors" do
    before { subject.increment.increment.increment.increment }
    it("does not generate life") { expect_generates_life false }
    it("does not support life") { expect_supports_life false }
  end
end

describe Cell do
  subject { Cell.new(nil) }
  let(:renderer) { double('renderer') }

  context "not alive" do
    it "reports dead cell to renderer" do
      renderer.should_receive(:dead_cell)
      subject.render_on renderer
    end

    it "should not increment the neighbor count" do
      count = double('neighbor count')
      count.should_not_receive(:increment)
      subject.update_neighbor_count count
    end
  end

  context "alive" do
    before { subject.live! }

    it "should render as X" do
      renderer.should_receive(:live_cell)
      subject.render_on renderer
    end

    it "should increment the neighbor count" do
      count = double('neighbor count')
      count.should_receive(:increment)
      subject.update_neighbor_count count
    end
  end
end
