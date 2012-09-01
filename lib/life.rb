require 'set'
require 'tell_dont_ask'
require 'space'

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
    @neighborhood.neighbors {|neighbor| neighbor.update_neighbor_count density }
    @aliveness.if_density_appropriate(density) { cell.live! }
  end

  def update_neighbor_count count
    @aliveness.update_count(count)
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

class Board < TellDontAsk
  def initialize h = nil
    @cells = h || Hash.new {|hash, tuple| hash[tuple] = Cell.new(Neighbors.new(self, tuple)) }
  end

  # TODO naming?
  def process position
    position.use_identifier {|id| yield @cells[id] }
  end
end
