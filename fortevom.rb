require_relative "./lexer.rb"
require_relative "./parser.rb"

file_given      = ARGV[0]
output_language = ARGV[1]

raise "You must provide a file"             if file_given.nil?
raise "You must provide an output language" if output_language.nil?

unless %w|cs php|.include?(output_language)
  puts "Invalid output language provided. Only use 'cs' to output C# or 'php' to output PHP."
  exit
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
  file_to_write_to = output_language == "php" ? file.sub(".fortevom", ".php") : file.sub(".fortevom", ".cs")
  lines            = getLines file
  line_number      = 0 # a rough approximate because it will be skewed if you have multiple expressions on one line

  lines.each do |line|
    line_number += 1
    if line == ' '
      snippets << line
    end

    expressions = getExpressions line

    # puts "expressions:"
    # expressions.each {|expression| puts expression}

    expressions.each do |expression|
      next if expression == " "
      token = lex expression
      
      # puts "token:"
      # pp token


      snippet = parser.parse token, output_language, line_number

      puts "snippet:"
      pp snippet

      # write snippet, file_to_write_to
    end
  end
end

orchestrate file_given, output_language
puts "Perfect! Your new file is named <placeholder>."


