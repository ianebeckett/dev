# ruby_lsp: try definition, references, and rename on greet.
class Greeter
  def greet(name)
    "Hello, #{name}"
  end
end

puts Greeter.new.greet("world")
# Uncomment for a syntax diagnostic (Ruby LSP is not a type checker):
# puts Greeter.new.greet(
