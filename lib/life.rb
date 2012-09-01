require 'set'
require 'tell_dont_ask'

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

  # TODO does this block belong out here?
  def update_cell_based_on_density density, cell
    @aliveness.if_density_appropriate(density) { cell.live! }
  end
end

# TODO is there a way to initialize this with neighbors, avoid dependency on board?
class Neighborhood < TellDontAsk
  def initialize board, coordinates
    @board = board
    @position = Position.new(*coordinates)
  end

  def neighbors &block
    @position.each_neighbor {|position| @board.process(position, &block) }
  end
end

# TODO bad name
class PopulationDensity < TellDontAsk
  def initialize
    @count = 0
  end

  def increment
    @count += 1
  end
  
  # TODO these yields are funny
  def if_generates_life
    yield if @count == 3
  end

  def if_supports_life
    yield if @count > 1 && @count < 4
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

class Board < TellDontAsk
  def initialize h = nil
    @cells = h || Hash.new {|hash, tuple| hash[tuple] = Cell.new(Neighborhood.new(self, tuple)) }
  end

  # TODO naming?
  def process position
    position.use_identifier {|id| yield @cells[id] }
  end
end
