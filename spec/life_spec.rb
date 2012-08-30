require 'life'

require 'stringio'

require 'rspec'
require "wrong/adapters/rspec"
Wrong.config.alias_assert :expect, :override => true

describe TextBoardRenderer do
  let(:output) { StringIO.new }
  subject { TextBoardRenderer.new(output) }

  it "renders live cells as X" do
    subject.live_cell
    expect { output.string == 'X' }
  end

  it "renders dead cells as ." do
    subject.dead_cell
    expect { output.string == '.' }
  end

  it "renders each row on a new line of text" do
    subject.end_row
    expect { output.string == "\n" }
  end
end

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
      subject.print_to renderer
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
      subject.print_to renderer
    end

    it "should increment the neighbor count" do
      count = double('neighbor count')
      count.should_receive(:increment)
      subject.update_neighbor_count count
    end
  end
end

describe World do
  def check_output expected_output
    output = StringIO.new
    subject.print_to output
    expect { output.string == expected_output }
  end

  context "with no cells on it" do
    subject { World.new() }

    it "prints a grid of empty cells to a stream" do
      check_output ".....\n" * 5
    end
  end

  context "with cells on it" do
    subject do
      World.new(Position.new(4, 4), Position.new(2, 1))
    end
    
    it "prints a grid of cells to a stream" do
      check_output <<HERE
.....
..X..
.....
.....
....X
HERE
    end
  end

  context "with one cell" do
    subject { World.new(Position.new(1, 1)) }
    
    it "will be empty in the next generation" do
      subject.tick
      check_output ".....\n" * 5
    end
  end

  context "with a two by two square on it" do
    subject { World.new(Position.new(1, 1), Position.new(2, 1), Position.new(1, 2), Position.new(2, 2)) }

    it "does not change in the next generation" do
      subject.tick
      check_output <<HERE
.....
.XX..
.XX..
.....
.....
HERE
    end
  end

  context "with a blinker" do
    subject { World.new(Position.new(1, 2), Position.new(2, 2), Position.new(3, 2)) }

    it "starts out looking like this" do
      check_output <<HERE
.....
.....
.XXX.
.....
.....
HERE
    end

    it "in the next generation it looks like this" do
      subject.tick
      check_output <<HERE
.....
..X..
..X..
..X..
.....
HERE
    end
  end
end











