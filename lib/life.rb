require 'set'

class Cell
  def initialize coordinates, board_hash
    @representation = '.'
  end

  def print_to output
    output.printf @representation
  end

  def live!
    @representation = 'X'
  end
end

class Board
  def initialize(*cell_coordinate_tuples)
    @cell_hash = Hash.new {|hash, tuple| hash[tuple] = Cell.new(tuple, hash) }
    cell_coordinate_tuples.each {|tuple| @cell_hash[tuple].live! }
  end

  def print_to stream
    (0..4).each {|y| print_row y, stream }
    return self
  end

  def tick
    next_generation = Hash.new {|hash, tuple| hash[tuple] = Cell.new(tuple, hash) }
    @cell_hash = next_generation
    return self
  end

  private 

  def print_row y, stream
      (0..4).each {|x| print_cell(x, y, stream) }
      stream.print "\n"
  end
  
  def print_cell x, y, stream
    @cell_hash[[x, y]].print_to stream
  end
end

class FutureCell
  def initialize coordinates_tuple, next_generation
    @coordinates_tuple = coordinates_tuple
    @next_generation = next_generation
  end

  def live!
    @next_generation.add @coordinates_tuple
    return self
  end
end
