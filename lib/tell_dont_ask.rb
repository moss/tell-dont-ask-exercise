class TellDontAsk
  @@rewritten_methods_by_class = Hash.new {|h, k| h[k] = [] }

  private

  def returning_self
    yield
    return self
  end

  def self.method_added name
    return if rewritten_methods.include? name
    rewrite_method_to_return_self name
  end

  def self.rewritten_methods
    @@rewritten_methods_by_class[self]
  end

  def self.rewrite_method_to_return_self name
    rewritten_methods << name
    original_definition = instance_method(name)
    define_new_version_of_method original_definition, name
  end

  def self.define_new_version_of_method original_definition, name
    define_method(name) do |*args, &block|
      returning_self { original_definition.bind(self).call(*args, &block) }
    end
  end
end
