require 'space'
require 'set'
require 'spec_helper'

class ObservedPositions
  include Wrong

  def initialize
    @positions = Set.new
  end

  def process position
    position.use_identifier {|id| @positions.add id }
  end

  def should_include *expected_positions
    expect { expected_positions.size == @positions.size }
    expected_positions.each {|p| should_include_position p }
  end

  def should_include_position expected_position
    expected_position.use_identifier do |id|
      expect { @positions.include? id }
    end
  end
end

describe Positions do
  let (:observed_positions) { ObservedPositions.new }

  before { subject.on_board observed_positions }

  context "from a list of positions" do
    let (:position_1) { Position.new(2, 3) }
    let (:position_2) { Position.new(5, 8) }
    subject { Positions.new([position_1, position_2]) }

    it "processes all of its positions in one go" do
      observed_positions.should_include position_1, position_2
    end
  end

  context "in a grid" do
    let (:grid) { Grid.new(1..2, 5..7) }
    subject { Positions.new(grid) }

    it "processes positions in the range of rows and columsn for the grid" do
      observed_positions.should_include(
        Position.new(5, 1), Position.new(6, 1), Position.new(7, 1),
        Position.new(5, 2), Position.new(6, 2), Position.new(7, 2))
    end
  end

  context "in a neighborhood" do
    let (:neighborhood) { Neighborhood.new(Position.new(2, 3)) }
    subject { Positions.new(neighborhood) }

    it "processes positions in the neighborhood of its center position" do
      observed_positions.should_include(
        Position.new(1, 2), Position.new(2, 2), Position.new(3, 2),
        Position.new(1, 3), Position.new(3, 3),
        Position.new(1, 4), Position.new(2, 4), Position.new(3, 4))
    end
  end
end

