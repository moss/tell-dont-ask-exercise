require 'set'

class Dead
  def print_to output
    output.printf '.'
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
  def print_to output
    output.printf 'X'
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
  def initialize coordinates, board_hash
    @neighborhood = Neighborhood.new(board_hash, coordinates[0], coordinates[1])
    @aliveness = Dead.new
  end

  def print_to output
    @aliveness.print_to output
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
  def initialize board_hash, x, y
    @board_hash = board_hash
    @x = x
    @y = y
  end

  def neighbors &block
    offsets do |xoffset|
      offsets {|yoffset| process_neighbor xoffset, yoffset, &block }
    end
  end

  private

  def process_neighbor xoffset, yoffset
    yield @board_hash[[@x + xoffset, @y + yoffset]] unless xoffset == 0 && yoffset == 0
    return self
  end

  def offsets &block
    [-1, 0, 1].each(&block)
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

class Board
  def initialize(*cell_coordinate_tuples)
    create_next_generation
    advance_current_generation
    cell_coordinate_tuples.each {|tuple| @cell_hash[tuple].live! }
  end

  def print_to stream
    (0..4).each {|y| print_row y, stream }
    return self
  end

  def tick
    create_next_generation
    calculate_next_generation
    advance_current_generation
  end

  private 

  def create_next_generation
    @next_generation = Hash.new {|hash, tuple| hash[tuple] = Cell.new(tuple, hash) }
    return self
  end

  def calculate_next_generation
    each_interesting_position do |tuple|
      @cell_hash[tuple].update_future_self(@next_generation[tuple])
    end
  end

  def advance_current_generation
    @cell_hash = @next_generation
    return self
  end

  def each_interesting_position
    (0..4).each {|y| (0..4).each {|x| yield [x, y] } }
    return self
  end

  def print_row y, stream
    (0..4).each {|x| print_cell(x, y, stream) }
    stream.print "\n"
    return self
  end
  
  def print_cell x, y, stream
    @cell_hash[[x, y]].print_to stream
    return self
  end
end
