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

class StateTransition < TellDontAsk
  def initialize current_generation, listener
    @next_generation = Board.new
    @generation_pair = GenerationPair.new(current_generation, @next_generation)
    @listener = listener
  end

  def calculate_next_generation
    make_next_generation
    notify_listener
  end

  private

  def make_next_generation
    grid = Grid.new(0..4, 0..4)
    Positions.new(grid).on_board(@generation_pair) {|current, future| update_future_cell(current, future) }
  end

  def notify_listener
    @listener.new_board @next_generation
  end

  def update_future_cell current, future
    density = PopulationDensity.new
    current.neighbors {|neighbor| neighbor.update_neighbor_count density }
    current.if_density_appropriate(density) { future.live! }
  end
end

class GenerationPair < TellDontAsk
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
