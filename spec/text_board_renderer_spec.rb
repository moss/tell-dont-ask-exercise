require 'text_board_renderer'
require 'stringio'
require 'spec_helper'

describe TextBoardRenderer do
  let(:output) { StringIO.new }
  subject { TextBoardRenderer.new(output) }

  it "renders live cells as X" do
    subject.live_cell
    expect { output.string == 'X' }
  end

  it "renders dead cells as ." do
    subject.dead_cell
    expect { output.string == '.' }
  end

  it "renders each row on a new line of text" do
    subject.end_row
    expect { output.string == "\n" }
  end
end
