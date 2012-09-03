require 'tell_dont_ask'

# TODO I cannot begin to see how to test this in isolation.
# Which is a code smell.

class Viewport < TellDontAsk
  def initialize
    @rows = (0..4).collect {|y| ViewportRow.new(y) }
  end

  def render_on renderer, board = nil
    @rows.each {|row| row.render_on renderer, board }
  end
end

class ViewportRow < TellDontAsk
  def initialize y
    @printable_cells = (0..4).collect {|x| ViewportCell.new(x, y) }
  end

  def render_on renderer, board
    @printable_cells.each {|cell| cell.render_on(renderer, board) }
    renderer.end_row
  end
end

class ViewportCell < TellDontAsk
  def initialize x, y
    @position = Position.new(x, y)
  end

  def render_on renderer, board
    board.process(@position) {|cell| cell.render_on renderer }
  end
end
