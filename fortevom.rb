require_relative "./lexer.rb"
require_relative "./parser.rb"

file_given      = ARGV[0]
output_language = ARGV[1]

raise "You must provide a file"             if file_given.nil?
raise "You must provide an output language" if output_language.nil?

unless %w|cs php|.include?(output_language)
  raise "Invalid output language provided. Only use 'cs' to output C# or 'php' to output PHP."
end

def write snippet, file_to_write_to
  begin
    File.write(file_to_write_to, snippet)
  rescue => exception
    puts "An exception was raised whilst trying to write to #{file_to_write_to}. Exception: #{exception}"
  end
end

def orchestrate file, output_language
  parser           = Parser.new()
  file_to_write_to = output_language == "php" ? file.sub!(".fortevom", ".php") : file.sub!(".fortevom", ".cs")
  lines            = getLines file_given

  lines.each do |line|
  if line == ' '
    snippets << line
  end


  expression = getExpression line
  token      = lex expression
  snippet    = parser.parse token, output_language

  write snippet, file_to_write_to

  puts "Perfect! Your new file is named #{file_to_write_to}."
  end
end

orchestrate file_given, output_language

