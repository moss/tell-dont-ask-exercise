require 'set'

class Cell
  def initialize coordinates, board_hash
    @representation = '.'
  end

  def print_to output
    output.printf @representation
    return self
  end

  def live!
    @representation = 'X'
    return self
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

  def each_interesting_position
    (0..4).each {|y| (0..4).each {|x| yield [x, y] } }
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
