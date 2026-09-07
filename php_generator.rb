
def phpGenerateComment comment
  <<-END
    // #{comment}
  END
end

def phpGenerateVariable type, name, value
  # type isn't used but it's needed
  <<-END
  $#{name} = #{value};
  END
end

def phpGenerateIf condition
  <<-END
  if (#{condition}) {
  END
end

def phpGenerateElseIf condition
  <<-END
  } elseif (#{condition}) {
  END
end

def phpGenerateElse
  <<-END
} else {
  END
end

def phpGenerateEnd
  <<-END
}
  END
end

def phpGenerateInferredVariable name, value
  <<-END
  $#{name} = #{value};
  END
end

def phpGenerateFunctionCall name, arguments
  # check if its a fortevom function like write_output() or read_stdin()
  return "echo #{arguments}"   if name == "write_output"
  return "readline()"          if name == "read_stdin"

  <<-END
  #{name}(#{arguments})
  END
end

def phpGenerateFunctionDeclaration name, arguments
  <<-END
  function #{name} (#{arguments})
  END
end

def phpGenerateWhileLoop condition
  # if the user is checking for a boolean value or a variable
  if condition =~ /^\w+$/
    return <<-END
    while ($#{condition}) {
    END
  end
  <<-END
  while (#{condition}) {
  END
end

def phpGenerateForLoop initialization, condition, update
  # NEEDS TESTING
  <<-END
  $#{initialization};
  while ($#{condition}) {
    $#{update}
  END
end

def phpGenerateForeachLoop iterator, array
  <<-END
  foreach ($#{array} as $#{iterator}) {
  END
end

def phpGenerateImport package
  return "\n" # doesn't exist in PHP
end

def phpGenerateImportFrom package, thing
  return "\n" # doesn't exist in PHP either
end

def transpileMethod method, variable, arguments
  return case method
  when "length"   then "count"
  when "pushTAIL" then "array_push"
  when "pushHEAD" then "array_unshift"
  when "find"     then "array_search"
  when "head"     then "array_last"
  when "tail"     then "array_first"
  end
end

def phpGenerateMethod variable, method, arguments
  # array[i] will not reach this function, so I need to figure that out.
  method = transpileMethod method
  return "#{method}"
end

def phpGenerateAttempt
  <<-END
  try {
  END
end

def phpGenerateCatchException exception
  <<-END
} catch (#{exception}) {
  END
end

def phpGenerateNamedException exception, name
  <<-END
} catch (#{exception} #{name}) {
  END
end