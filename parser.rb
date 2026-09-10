
require_relative "csharp_generator"
require_relative "php_generator"
require_relative "lexer"

class Parser
  def initialize
    @recognized_types  = %w|uint int boolean float string char obj any|
  end
  
  # this will need to be refactored to support nesting

  def parse token, output_language, line_number
    # refactor every other function call to use send()
    # remember to turn =/= into !=

    # puts "DEBUG:"
    # pp token
    # puts token[:type]


    snippet = case token[:type]
    when :comment
      return send("#{output_language}GenerateComment", token[:comment])
    when :variable_creation
      fail "Invalid type assigned to #{token[:name]}: #{token[:var_type]} on line ~#{line_number}" unless @recognized_types.include?(token[:var_type])

      return send("#{output_language}GenerateVariable", token[:var_type], token[:name], token[:value])

    when :if_condition
      return send("#{output_language}GenerateIf", token[:condition])

    when :alternative_condition
      return send("#{output_language}GenerateElseIf", token[:condition])

    when :otherwise_condition
      return send("#{output_language}GenerateElse")

    when :end
      return send("#{output_language}GenerateEnd")

    when :inferred_variable_creation
      return send("#{output_language}GenerateInferredVariable", token[:name], token[:value])

    when :function_call
      return send("#{output_language}GenerateFunctionCall", token[:function_name], token[:arguments])

    when :function_declaration
      return send("#{output_language}GenerateFunctionDeclaration", token [:function_name], token[:arguments])

    when :while_loop
      return send("#{output_language}GenerateWhileLoop", token[:condition])

    when :for_loop
      return send("#{output_language}GenerateForLoop", token[:initialization], token[:condition], token[:update])

    when :foreach_loop
      return send("#{output_language}GenerateForeachLoop", token[:iterator], token[:array])

    when :import
      return send("#{output_language}GenerateImport", token[:package])

    when :import_as
      return csGenerateImportFrom token[:package], token[:thing]


    when :method
      newMethod = lexMethod token[:method]
      return csGenerateMethod token[:variable], newMethod, token[:arguments]

    when :open_attempt_block
      return csGenerateAttempt

    when :unnamed_when_arm
      return csGenerateCatchException token[:exception]

    when :named_when_arm
      return csGenerateNamedException token[:exception], token[:name]

    else
      return "\n"
    end
    
    return snippet
  end
end