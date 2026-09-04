
require_relative "csharp_generator"
require_relative "lexer"

class Parser
  def initialize
    @insideConditional = false
    @insideLoop        = false
    @insideAttempt     = false
  end
  
  # the separation of power is kinda fucked because the lexer is almost a parser
  # so the parser really just routes and does a tiny bit of verification

  # this will need to be refactored to support nesting

  def parse token, output_language
    fail "The given language will not work: #{output_language}" unless %w|cs php|.include?(output_language)
      
    # refactor every other function call to use send()
    # remember to turn =/= into !=

    snippet = case token[:type]
    when "comment"
      return send("#{output_language}GenerateComment", token[:comment])
    when "variable_creation"
      return csGenerateVariable token[:var_type], token[:name], token[:value]
    when "if_condition"
      newCondition = lex token[:condition] # incase they embedded Fortevom syntax into the condition
      return csGenerateIf newCondition
    when "alternative_condition"
      insideConditional or raise "Unexpected alternative clause: you are not inside a conditonal."
      newCondition = lex token[:condition]
      return csGenerateElseIf newCondition
    when "otherwise_condition"
      insideConditional or raise "Unexpected otherwise clause: you are not inside a conditonal."
      return csGenerateElse
    when "end"
      fail "Unexpected end; there are no conditionals or loops to close." unless @insideConditional || @insideLoop || @insideAttempt
      @insideConditional = false if @insideConditional
      @insideLoop        = false if @insideLoop
      @insideAttempt     = false if @insideAttempt
      return csGenerateEnd
    when "inferred_variable_creation"
      return csGenerateInferredVariable token[:name], token[:value]
    when "function_call"
      return csGenerateFunctionCall token[:function_name], token[:arguments]
    when "function_declaration"
      return csGenerateFunctionDeclaration token [:function_name], token[:arguments]
    when "while_loop"
      return csGenerateWhileLoop token[:condition]
    when "for_loop"
      return csGenerateForLoop token[:initialization], token[:condition], token[:update]
    when "foreach_loop"
      return csGenerateForeachLoop token[:iterator], token[:array]
    when "import"
      return csGenerateImport token[:package]
    when "import_as"
      return csGenerateImportFrom token[:package], token[:thing]
    when "method"
      newMethod = lexMethod token[:method]
      return csGenerateMethod token[:variable], newMethod
    when "open_attempt_block"
      return csGenerateAttempt
    when "unnamed_when_arm"
      return csGenerateCatchException token[:exception]
    when "named_when_arm"
      return csGenerateNamedException token[:exception], token[:name]
    else
      raise "An error occured within the parser. Failed to route type: #{token[:type]}"
    end
    
    return snippet
  end
end