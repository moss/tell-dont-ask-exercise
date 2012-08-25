require 'life'

require 'stringio'

require 'rspec'
require "wrong/adapters/rspec"
Wrong.config.alias_assert :expect, :override => true

describe PopulationDensity do
  subject { PopulationDensity.new }

  context "with two neighbors" do
    before { subject.increment.increment }

    it "is not lively" do
      lively = false
      subject.if_lively { lively = true }
      expect { !lively }
    end
  end

  context "with three neighbors" do
    before { subject.increment.increment.increment }

    it "is lively" do
      lively = false
      subject.if_lively { lively = true }
      expect { lively }
    end
  end
end

describe Cell do
  subject { Cell.new(nil, nil) }

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
  context "with no cells on it" do
    subject { Board.new() }

    it "prints a grid of empty cells to a stream" do
      output = StringIO.new
      subject.print_to output
      expected_output = <<HERE
.....
.....
.....
.....
.....
HERE
      expect { output.string == expected_output }
    end
  end

  context "with cells on it" do
    subject do
      Board.new([4, 4], [2, 1])
    end
    
    it "prints a grid of cells to a stream" do
      output = StringIO.new
      subject.print_to output
      expected_output = <<HERE
.....
..X..
.....
.....
....X
HERE
      expect { output.string == expected_output }
    end
  end

  context "with one cell" do
    subject { Board.new([1, 1]) }
    
    it "will be empty in the next generation" do
      output = StringIO.new
      subject.tick.print_to output
      expect { output.string == ".....\n" * 5 }
    end
  end

  context "with a two by two square on it" do
    subject { Board.new([1, 1], [2, 1], [1, 2], [2, 2]) }

    it "does not change in the next generation" do
      output = StringIO.new
      subject.tick.print_to output
      expected_output = <<HERE
.....
.XX..
.XX..
.....
.....
HERE
      expect { output.string == expected_output }
    end
  end

  context "with a blinker" do
    subject { Board.new([1, 2], [2, 2], [3, 2]) }

    it "starts out looking like this" do
      output = StringIO.new
      subject.print_to output
      expected_output = <<HERE
.....
.....
.XXX.
.....
.....
HERE
      expect { output.string == expected_output }
    end

    pending "in the next generation it looks like this" do
      output = StringIO.new
      subject.tick.print_to output
      expected_output = <<HERE
.....
..X..
..X..
..X..
.....
HERE
      expect { output.string == expected_output }
    end
  end
end











