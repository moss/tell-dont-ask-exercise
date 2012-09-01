require 'tell_dont_ask'

class Position < TellDontAsk
  def initialize x, y
    @x = x
    @y = y
  end

  def use_identifier
    yield [@x, @y]
  end

  # TODO this is bulky and awkward. Alternatives?
  def each_neighbor
    offsets do |xoff|
      offsets {|yoff| yield Position.new(@x + xoff, @y + yoff) unless xoff == 0 && yoff == 0 }
    end
  end

  private

  def offsets &block
    [-1, 0, 1].each(&block)
  end
end

class Grid < TellDontAsk
  def initialize rows, columns
    @rows = rows
    @columns = columns
  end

  def each
    @rows.each {|y|
      @columns.each {|x| yield Position.new(x, y) }
    }
  end
end

class Positions < TellDontAsk
  def initialize positions
    @positions = positions
  end

  def on_board board, &block
    @positions.each {|position| board.process(position, &block) }
  end
end

class Neighborhood < TellDontAsk
  def initialize board, coordinates
    @board = board
    @position = Position.new(*coordinates)
  end

  def neighbors &block
    @position.each_neighbor {|position| @board.process(position, &block) }
  end
end
