
def csGenerateComment content
  <<-END
    
  END
end

def csGenerateVariable type, name, value
  <<-END
    
  END
end

def csGenerateIf condition
  <<-END
    
  END
end

def csGenerateElseIf condition
  <<-END
  
  END
end

def csGenerateElse
  <<-END
  
  END
end

def csGenerateEnd
  <<-END
  
  END
end

def csGenerateInferredVariable name, value
  <<-END
    
  END
end

def csGenerateFunctionCall name, arguments
  <<-END
  
  END
end

def csGenerateFunctionDeclaration name, arguments
  <<-END
  
  END
end

def csGenerateWhileLoop condition
  <<-END
  
  END
end

def csGenerateForLoop initialization, condition, update
  <<-END
  
  END
end

def csGenerateForeachLoop iterator, array
  <<-END
  
  END
end

def csGenerateImport package
  <<-END
  
  END
end

def csGenerateImportFrom package, thing
  <<-END
  
  END
end

def csGenerateMethod variable, method
  <<-END
    
  END
end

def csGenerateAttempt
  <<-END
    
  END
end

def csGenerateCatchException exception
  <<-END
  
  END
end

def csGenerateNamedException exception, name
  <<-END
  
  END
end

