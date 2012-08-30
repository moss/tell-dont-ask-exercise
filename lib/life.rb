require 'set'

class TellDontAsk
  @@handled_methods = []

  def self.method_added name
    return if @@handled_methods.include? name
    @@handled_methods << name
    original_definition = instance_method(name)
    define_method(name) do |*args, &block|
      original_definition.bind(self).call(*args, &block)
      return self
    end
  end
end

class TextBoardRenderer < TellDontAsk
  def initialize output
    @output = output
  end

  def live_cell
    @output.printf 'X'
  end

  def dead_cell
    @output.printf '.'
  end

  def end_row
    @output.printf "\n"
  end
end

class Dead < TellDontAsk
  def render_on renderer
    renderer.dead_cell
  end

  def update_count count
  end

  def if_density_appropriate density
    density.if_generates_life { yield }
  end
end

class Alive < TellDontAsk
  def render_on renderer
    renderer.live_cell
  end

  def update_count count
    count.increment
  end

  def if_density_appropriate density
    density.if_supports_life { yield }
  end
end

class Cell < TellDontAsk
  def initialize neighborhood
    @neighborhood = neighborhood
    @aliveness = Dead.new
  end

  def render_on renderer
    @aliveness.render_on renderer
  end

  def live!
    @aliveness = Alive.new
  end

  def update_future_self cell
    density = PopulationDensity.new
    count_neighbors density
    update_cell_based_on_density(density, cell)
  end

  def update_neighbor_count count
    @aliveness.update_count(count)
  end

  def count_neighbors density
    @neighborhood.neighbors {|neighbor| neighbor.update_neighbor_count density }
  end

  private

  def update_cell_based_on_density density, cell
    @aliveness.if_density_appropriate(density) { cell.live! }
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

class PopulationDensity < TellDontAsk
  def initialize
    @count = 0
  end

  def increment
    @count += 1
  end
  
  def if_generates_life
    yield if @count == 3
  end

  def if_supports_life
    yield if @count > 1 && @count < 4
  end
end

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

  def create_next_generation
    @next_generation = Board.new
  end

  def calculate_next_generation
    each_interesting_position do |position|
      @current_generation.process(position) {|current_cell|
        @next_generation.process(position) {|future_cell|
          current_cell.update_future_self(future_cell)
        }
      }
    end
  end

  def advance_current_generation
    @current_generation = @next_generation
  end

  def each_interesting_position
    (0..4).each {|y| (0..4).each {|x| yield Position.new(x, y) } }
  end
end

class Position < TellDontAsk
  def initialize x, y
    @x = x
    @y = y
  end

  def use_identifier
    yield [@x, @y]
  end

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

class Board < TellDontAsk
  def initialize h = nil
    @cells = h || Hash.new {|hash, tuple| hash[tuple] = Cell.new(Neighborhood.new(self, tuple)) }
  end

  def process position
    position.use_identifier {|id| yield @cells[id] }
  end
end

class PrintableGrid < TellDontAsk
  def initialize
    @rows = (0..4).collect {|y| PrintableRow.new(y) }
  end

  def render_on renderer, board = nil
    @rows.each {|row| row.render_on renderer, board }
  end
end

class PrintableRow < TellDontAsk
  def initialize y
    @printable_cells = (0..4).collect {|x| PrintableCell.new(x, y) }
  end

  def render_on renderer, board
    @printable_cells.each {|cell| cell.render_on(renderer, board) }
    renderer.end_row
  end
end

class PrintableCell < TellDontAsk
  def initialize x, y
    @position = Position.new(x, y)
  end

  def render_on renderer, board
    board.process(@position) {|cell| cell.render_on renderer }
  end
end
