require 'tell_dont_ask'

# TODO naming is now wrong
class PrintableGrid < TellDontAsk
  def initialize
    @rows = (0..4).collect {|y| PrintableRow.new(y) }
  end

  def render_on renderer, board = nil
    @rows.each {|row| row.render_on renderer, board }
  end
end

# TODO naming is now wrong
class PrintableRow < TellDontAsk
  def initialize y
    @printable_cells = (0..4).collect {|x| PrintableCell.new(x, y) }
  end

  def render_on renderer, board
    @printable_cells.each {|cell| cell.render_on(renderer, board) }
    renderer.end_row
  end
end

# TODO naming is now wrong
# TODO need to be separate from Cell? Maybe -- I'm not sure.
class PrintableCell < TellDontAsk
  def initialize x, y
    @position = Position.new(x, y)
  end

  def render_on renderer, board
    board.process(@position) {|cell| cell.render_on renderer }
  end
end
