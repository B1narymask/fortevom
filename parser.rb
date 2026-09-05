
require_relative "csharp_generator"
require_relative "php_generator"
require_relative "lexer"

class Parser
  def initialize
    @insideConditional = false
    @insideLoop        = false
    @insideAttempt     = false
    @recognized_types  = %w|uint int boolean float string char obj any|
  end
  
  # this will need to be refactored to support nesting

  def parse token, output_language
    # refactor every other function call to use send()
    # remember to turn =/= into !=

    puts "DEBUG:"
    pp token
    puts token[:type]


    snippet = case token[:type]
    when :comment
      return send("#{output_language}GenerateComment", token[:comment])
    when "variable_creation"
      fail "Invalid type assigned to #{token[:name]}: #{token[:var_type]}" unless @recognized_types.include?(token[:var_type])

      return send("#{output_language}GenerateVariable", token[:var_type], token[:name], token[:value])
    when :if_condition
      newCondition = lex token[:condition] # incase they embedded Fortevom syntax into the condition
      return csGenerateIf newCondition
    when "alternative_condition"
      @insideConditional or raise "Unexpected alternative clause: you are not inside a conditonal."
      newCondition = lex token[:condition]
      return csGenerateElseIf newCondition
    when :otherwise_condition
      @insideConditional or raise "Unexpected otherwise clause: you are not inside a conditonal."
      return csGenerateElse
    when :end
      fail "Unexpected end; there are no conditionals or loops to close." unless @insideConditional || @insideLoop || @insideAttempt
      @insideConditional = false if @insideConditional
      @insideLoop        = false if @insideLoop
      @insideAttempt     = false if @insideAttempt
      return csGenerateEnd
    when :inferred_variable_creation
      return csGenerateInferredVariable token[:name], token[:value]
    when :function_call
      return csGenerateFunctionCall token[:function_name], token[:arguments]
    when :function_declaration
      return csGenerateFunctionDeclaration token [:function_name], token[:arguments]
    when :while_loop
      return csGenerateWhileLoop token[:condition]
    when :for_loop
      return csGenerateForLoop token[:initialization], token[:condition], token[:update]
    when :foreach_loop
      return csGenerateForeachLoop token[:iterator], token[:array]
    when :import
      return csGenerateImport token[:package]
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