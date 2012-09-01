require 'tell_dont_ask'
require 'life'
require 'viewport'
require 'text_board_renderer'

class Runner < TellDontAsk
  def initialize(*cell_positions)
    new_board Board.new
    Positions.new(cell_positions).on_board(@current_generation) {|cell| cell.live! }
  end

  def print_to output
    Viewport.new.render_on TextBoardRenderer.new(output), @current_generation
  end

  def tick
    StateTransition.new(@current_generation, self).calculate_next_generation
  end

  def new_board board
    @current_generation = board
  end
end

class StateTransition
  def initialize current_generation, listener
    @next_generation = Board.new
    @generation_pair = GenerationPair.new(current_generation, @next_generation)
    @listener = listener
  end

  def calculate_next_generation
    each_interesting_position {|current, future| current.update_future_self(future) }
    @listener.new_board @next_generation
  end

  private

  def each_interesting_position &block
    grid = Grid.new(0..4, 0..4)
    Positions.new(grid).on_board(@generation_pair, &block)
  end
end

class GenerationPair
  def initialize current_generation, next_generation
    @current_generation = current_generation
    @next_generation = next_generation
  end

  def process position
    @current_generation.process(position) {|current|
      @next_generation.process(position) {|future| yield current, future }
    }
  end
end

class Grid
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

class Positions
  def initialize positions
    @positions = positions
  end

  def on_board board, &block
    @positions.each {|position| board.process(position, &block) }
  end
end
