require 'set'

class Cell
  def initialize coordinates, board_hash
    @xy = coordinates
    @board_hash = board_hash
    @alive = false
  end

  def print_to output
    output.printf @alive ? 'X' : '.'
    return self
  end

  def live!
    @alive = true
    return self
  end

  def if_lives
    density = PopulationDensity.new
    count_neighbors density
    density.if_lively { yield }
    return self
  end

  def update_neighbor_count count
    count.increment if @alive
    return self
  end

  def count_neighbors density
    each_neighbor {|neighbor| neighbor.update_neighbor_count density }
  end

  private

  def each_neighbor
    [
      [@xy[0]-1, @xy[1]-1],
      [@xy[0]-1, @xy[1]],
      [@xy[0]-1, @xy[1]+1],
      [@xy[0], @xy[1]-1],
      [@xy[0], @xy[1]+1],
      [@xy[0]+1, @xy[1]-1],
      [@xy[0]+1, @xy[1]],
      [@xy[0]+1, @xy[1]+1]
    ].each {|coordinates| yield @board_hash[coordinates] }
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
  
  def if_lively
    yield if @count == 3
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
      @cell_hash[tuple].if_lives { @next_generation[tuple].live! }
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
