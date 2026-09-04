require_relative "./lexer.rb"

file_given = ARGV[0]

lines       = getLines file_given

lines.each do |line|
  expression = getExpression line
  token      = lex expression
  pp token
  # insert parser and generator stuff here
end

