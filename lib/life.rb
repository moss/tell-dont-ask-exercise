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

    return self
  end

  def advance_current_generation
    @cell_hash = @next_generation
    return self
  end

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
