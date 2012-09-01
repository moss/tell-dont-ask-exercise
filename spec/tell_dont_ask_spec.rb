require 'tell_dont_ask'
require 'spec_helper'

describe TellDontAsk do
  subject { SampleTellDontAsk.new }
  let(:other_example) { AnotherTellDontAsk.new }

  it "returns self from any method defined on it" do
    expect { subject.some_method == subject }
  end

  it "doesn't override methods inherited from Object" do
    expect { subject.to_s.instance_of? String }
    expect { !subject.to_s.instance_of? TellDontAsk }
  end

  it "even updates return values of methods that try to return something" do
    expect { subject.method_returning_int == subject }
  end

  it "still runs the body of the method" do
    collaborator = double('collaborator')
    collaborator.should_receive(:some_method_call)
    subject.call_some_method_on collaborator
  end

  it "still calls the block if the original method did" do
    value = 'did not update'
    subject.pass_result_to_block {|result| value = result }
    expect { value == 'updated' }
  end

  it "will handle methods with the same names on different classes" do
    expect { subject.some_method == subject }
    expect { other_example.some_method == other_example }
  end

  class SampleTellDontAsk < TellDontAsk
    def some_method; end
    def method_returning_int; return 42; end
    def call_some_method_on(collaborator); collaborator.some_method_call; end
    def pass_result_to_block; yield 'updated'; end
  end

  class AnotherTellDontAsk < TellDontAsk
    def some_method; end
  end
end
