

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
  when /if\s+(?<condition>.*)\s+then/ # note that this will also capture the shorthand checks so we need to compile those too
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
  when /end/
    {
      type: :end
    }
  when /infer\s+(?<name>.*)\s+=\s+(?<value>.*)/
    {
      type: :inferred_variable_creation,
      name: $~[:name],
      value: $~[:value]
    }
  when /(?<function_name>.*)\((?<arguments_list>.*?)\)/ # this will capture any word and then parens: xyz(?)
    {
      type: :function_call,
      function_name: $~[:function_name],
      arguments: $~[:arguments_list]
    }
  when /fn\s+(?<function_name>.*)\((?<arguments_list>.*?)\)\:/
    {
      type: :function_declaration,
      function_name: $~[:function_name],
      arguments: $~[:arguments_list],
    }
  when /while\s+(?<condition>.*)\s+do/
    {
      type: :while_loop,
      condition: $~[:condition]
    }
  when /for\s+(?<initialization>.*)\,(?<condition>.*)\,(?<update>.*)\s+do/
    {
      type: :for_loop,
      initialization: $~[:initialization],
      condition: $~[:condition],
      update: $~[:update]
    }
  when /for\s+(?<iterator>.*)\s+in\s+(?<array>.*)\s+do/
    {
      type: :foreach_loop,
      iterator: $~[:iterator],
      array: $~[:array]
    }
  when /import\s+(?<package>.*)/
    {
      type: :import,
      package: $~[:package]
    }
  when /import\s+(?<package>.*)\s+as\s+/
    {
      type: :import_as,
      package: $~[:package]
    }
  when /(?<variable>.*)\.(?<method>.*)$/
    {
      type: :method,
      variable: $~[:variable],
      method: $~[:method]
    }
  when /obj\s+(?<variable_name>.*)\s+=\s+\{/
    {
      type: :object_declaration,
      name: $~[:variable_name]
    }
  when /attempt:/
    {
      type: :open_attempt_block
    }
  when /when\s+(?<exception_type>.*)$/
    {
      type: :unnamed_when_arm,
      exception: $~[:exception_type]
    }
  when /when\s+(?<exception_type>)\s+(?<name>.*)$/
    {
      type: :named_when_arm,
      exception: $~[:exception_type],
      name: $~[:name]
    }
  end
end

# debug

# expressions = getExpressions("write_output('hi'); write_output('hi');")
# expressions.each do |expression|
#   puts expression
# end