

def getLines file
  File.exist?(file) or fail "The given file doesn't exist in this context: #{file}"
  lines = nil
  begin
    lines = File.readlines(file)
  rescue => error
    puts "Failed to read the file #{file}. Error: #{error}"
  end
  return lines
end

def getExpressions line
  return line.split(';').map { |expr| expr.strip.split.join(' ') }
end

# eventually we can swap this out with a more complex lexer
# returns a dictionary containing the data about the given expression
def lex expression
  return case expression
  when /°(?<comment>.*)/
    {
      type: :comment,
      comment: $~[:comment]
    }
  when /(?<type>(boolean|int|uint|string|char))\s+(?<var_name>.*)\s=\s(?<value>.*)\Z/
    {
      type: :variable_creation,
      var_type: $~[:type],
      name: $~[:var_name],
      value: $~[:value]
    }
  when /if\s+(?<condition>.*)\s+then/
    {
      type: :if_condition,
      condition: $~[:condition]
    }
  when /alternatively\s(?<condition>.*)\s+then/
    {
      type: :alternative_condition,
      condition: $~[:condition]
    }
  when /otherwise/
    {
      type: :otherwise_condition
    }
  end
end

# expressions = getExpressions("write_output('hi'); write_output('hi');")
# expressions.each do |expression|
#   puts expression
# end