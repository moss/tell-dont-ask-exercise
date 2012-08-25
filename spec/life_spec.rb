require 'life'

require 'stringio'

require 'rspec'
require "wrong/adapters/rspec"
Wrong.config.alias_assert :expect, :override => true

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

  context "not alive" do
    it "should render as ." do
      output = StringIO.new
      subject.print_to output
      expect { output.string == '.' }
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
      output = StringIO.new
      subject.print_to output
      expect { output.string == 'X' }
    end

    it "should increment the neighbor count" do
      count = double('neighbor count')
      count.should_receive(:increment)
      subject.update_neighbor_count count
    end
  end
end

describe Board do
  def check_output expected_output
    output = StringIO.new
    subject.print_to output
    expect { output.string == expected_output }
  end

  context "with no cells on it" do
    subject { Board.new() }

    it "prints a grid of empty cells to a stream" do
      check_output ".....\n" * 5
    end
  end

  context "with cells on it" do
    subject do
      Board.new([4, 4], [2, 1])
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
    subject { Board.new([1, 1]) }
    
    it "will be empty in the next generation" do
      subject.tick
      check_output ".....\n" * 5
    end
  end

  context "with a two by two square on it" do
    subject { Board.new([1, 1], [2, 1], [1, 2], [2, 2]) }

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
    subject { Board.new([1, 2], [2, 2], [3, 2]) }

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











