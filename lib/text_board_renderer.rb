require 'tell_dont_ask'

class TextBoardRenderer < TellDontAsk
  def initialize output
    @output = output
  end

  def live_cell
    @output.printf 'X'
  end

  def dead_cell
    @output.printf '.'
  end

  def end_row
    @output.printf "\n"
  end
end
