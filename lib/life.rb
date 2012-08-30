require 'set'

class TextBoardRenderer
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

class Dead
  def render_on renderer
    renderer.dead_cell
    return self
  end

  def update_count count
    return self
  end

  def if_density_appropriate density
    density.if_generates_life { yield }
    return self
  end
end

class Alive
  def render_on renderer
    renderer.live_cell
    return self
  end

  def update_count count
    count.increment
    return self
  end

  def if_density_appropriate density
    density.if_supports_life { yield }
    return self
  end
end

class Cell
  def initialize neighborhood
    @neighborhood = neighborhood
    @aliveness = Dead.new
  end

  def render_on renderer
    @aliveness.render_on renderer
    return self
  end

  def live!
    @aliveness = Alive.new
    return self
  end

  def update_future_self cell
    density = PopulationDensity.new
    count_neighbors density
    update_cell_based_on_density(density, cell)
  end

  def update_neighbor_count count
    @aliveness.update_count(count)
    return self
  end

  def count_neighbors density
    @neighborhood.neighbors {|neighbor| neighbor.update_neighbor_count density }
    return self
  end

  private

  def update_cell_based_on_density density, cell
    @aliveness.if_density_appropriate(density) { cell.live! }
    return self
  end
end

class Neighborhood
  def initialize board, coordinates
    @board = board
    @position = Position.new(*coordinates)
  end

  def neighbors &block
    @position.each_neighbor {|position| @board.process(position, &block) }
    return self
  end
end

class PopulationDensity
  def initialize
    @count = 0
  end

  def increment
    @count += 1
    return self
  end
  
  def if_generates_life
    yield if @count == 3
    return self
  end

  def if_supports_life
    yield if @count > 1 && @count < 4
    return self
  end
end

class World
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
    return self
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
    return self
  end

  def each_interesting_position
    (0..4).each {|y| (0..4).each {|x| yield Position.new(x, y) } }
    return self
  end
end

class Position
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
    return self
  end
end

class Board
  def initialize h = nil
    @cells = h || Hash.new {|hash, tuple| hash[tuple] = Cell.new(Neighborhood.new(self, tuple)) }
  end

  def process position
    position.use_identifier {|id| yield @cells[id] }
    return self
  end
end

class PrintableGrid
  def initialize
    @rows = (0..4).collect {|y| PrintableRow.new(y) }
  end

  def render_on renderer, board = nil
    @rows.each {|row| row.render_on renderer, board }
    return self
  end
end

class PrintableRow
  def initialize y
    @printable_cells = (0..4).collect {|x| PrintableCell.new(x, y) }
  end

  def render_on renderer, board
    @printable_cells.each {|cell| cell.render_on(renderer, board) }
    renderer.end_row
    return self
  end
end

class PrintableCell
  def initialize x, y
    @position = Position.new(x, y)
  end

  def render_on renderer, board
    board.process(@position) {|cell| cell.render_on renderer }
    return self
  end
end
