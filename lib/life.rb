require 'set'

class Board
  def initialize(*cell_coordinate_tuples)
    @live_cells = Set.new(cell_coordinate_tuples)
  end

  def print_to stream
    (0..4).each {|y| print_row y, stream }
    return self
  end

  def tick
    next_generation = Set.new
    @live_cells = next_generation
    return self
  end

  private 

  def print_row y, stream
      (0..4).each {|x| print_cell(x, y, stream) }
      stream.print "\n"
  end
  
  def print_cell x, y, stream
    output = @live_cells.include?([x, y]) ? 'X' : '.'
    stream.print output
  end
end

class FutureCell
end
