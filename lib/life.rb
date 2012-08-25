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
  def initialize neighborhood
    @neighborhood = neighborhood
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
  def initialize generation, coordinates
    @generation = generation
    @x, @y = coordinates
  end

  def neighbors &block
    offsets do |xoffset|
      offsets {|yoffset| process_neighbor xoffset, yoffset, &block }
    end
  end

  private

  def process_neighbor xoffset, yoffset, &block
    @generation.process(Position.new(@x + xoffset, @y + yoffset), &block) unless xoffset == 0 && yoffset == 0
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
  def initialize(*cell_positions)
    create_next_generation
    advance_current_generation
    cell_positions.each {|position| @current_generation.process(position) {|cell| cell.live! } }
  end

  def print_to stream
    PrintableGrid.new(@current_generation).print stream
  end

  def tick
    create_next_generation
    calculate_next_generation
    advance_current_generation
  end

  private 

  def create_next_generation
    @next_hash = Hash.new {|hash, tuple| hash[tuple] = Cell.new(Neighborhood.new(Generation.new(hash), tuple)) }
    @next_generation = Generation.new(@next_hash)
    return self
  end

  def calculate_next_generation
    each_interesting_position do |tuple|
      @cell_hash[tuple].update_future_self(@next_hash[tuple])
    end
  end

  def advance_current_generation
    @cell_hash = @next_hash
    @current_generation = @next_generation
    return self
  end

  def each_interesting_position
    (0..4).each {|y| (0..4).each {|x| yield [x, y] } }
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
end

class Generation
  def initialize board_hash
    @board_hash = board_hash
  end

  def process position
    position.use_identifier {|id| yield @board_hash[id] }
    return self
  end
end

class PrintableGrid
  def initialize generation
    @generation = generation
  end

  def print stream
    (0..4).each {|y| PrintableRow.new(y, @generation).print stream }
    return self
  end
end

class PrintableRow
  def initialize y, generation
    @y = y
    @generation = generation
  end

  def print stream
    (0..4).each {|x| print_cell(x, @y, stream) }
    stream.print "\n"
    return self
  end

  private
  
  def print_cell x, y, stream
    @generation.process(Position.new(x, y)) {|cell| cell.print_to stream }
    return self
  end
end
