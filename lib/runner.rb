require 'tell_dont_ask'
require 'life'
require 'viewport'
require 'text_board_renderer'

# TODO naming?
class World < TellDontAsk
  def initialize(*cell_positions)
    create_next_generation
    advance_current_generation
    cell_positions.each {|position| @current_generation.process(position) {|cell| cell.live! } }
  end

  def print_to output
    PrintableGrid.new.render_on TextBoardRenderer.new(output), @current_generation
  end

  def tick
    create_next_generation
    calculate_next_generation
    advance_current_generation
  end

  private 

  # TODO get these private methods somewhere else
  def create_next_generation
    @next_generation = Board.new
  end

  def calculate_next_generation
    each_interesting_position do |current, future|
      current.update_future_self(future)
    end
  end

  def advance_current_generation
    @current_generation = @next_generation
  end

  def each_interesting_position &block
    (0..4).each {|y|
      (0..4).each {|x| process_current_and_future Position.new(x, y), &block }
    }
  end

  def process_current_and_future position
    @current_generation.process(position) {|current|
      @next_generation.process(position) {|future| yield current, future }
    }
  end
end
