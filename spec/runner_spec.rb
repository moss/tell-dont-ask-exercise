require 'runner'
require 'stringio'
require 'spec_helper'

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
