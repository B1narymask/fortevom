require_relative "./lexer.rb"
require_relative "./parser.rb"

command         = ARGV[0]
file_given      = ARGV[1]
output_language = ARGV[2]

unless %w|lex parse compile transpile render digest|.include?(command)
  if command =~ /(\w+)?\/(\w+)/
    puts "Looks like you forgot to add a command. Remember to include a command before your directory like 'compile'."
    exit
  end
  
  if command == nil || command == ''
    puts "You must provide a command."
    exit
  else
    puts "Invalid command: #{command}"
    exit
  end

end

raise "You must provide a file"             if file_given.nil?
raise "You must provide an output language" if output_language.nil? && command != "lex"

unless %w|cs php|.include?(output_language) && command != "lex"
  puts "Invalid output language provided. Only use 'cs' to output C# or 'php' to output PHP."
  exit
end

def write snippet, file_to_write_to
  # puts "WRITING"
  # puts "SNIPPET:"
  # puts snippet
  # puts "FILE:"
  # puts file_to_write_to

  begin
    snippet = "#{snippet.lstrip}\n"
    File.write(file_to_write_to, snippet, mode: 'a')
  rescue => exception
    puts "An exception was raised whilst trying to write to #{file_to_write_to}. Exception: #{exception}"
  end
end

def compile file, output_language
  # fail "The file given -- #{file} -- does not the .fortevom extension." unless File.extname(file) == ".fortevom"

  parser           = Parser.new()
  file_to_write_to = output_language == "php" ? "#{File.basename(file)}.php" : "#{File.basename(file)}.cs"
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

      # puts "snippet:"
      # pp snippet

      write snippet, file_to_write_to
    end
  end
  return file_to_write_to
end

def onlyLex file
  lines = getLines(file)
  tokens = []
  lines.each do |line|
    token = lex line
    tokens << token
  end
  
  puts "TOKEN OUTPUT OF #{file}:"
  tokens.each { |token| puts token }
end

def onlyParse file, language
  lines = getLines(file)
  tokens = []
  lines.each do |line|
    token = lex line
    tokens << token
  end

  line_number = 1
  snippets = []

  tokens.each do |token|
    snippet = parse token, language, line_number
    snippets << snippet
    line_number += 1
  end

  puts "CODE SNIPPETS GENERATED FROM #{file} IN #{language}:"
  snippets.each { |snippet| puts snippet }
end


def orchestrate file_given, output_language
  output_file = compile file_given, output_language

  unless File.zero?(output_file)
    puts <<~END
      Notice:
      It looks like your output file may already have text in it.
      Sadly, Fortevom has a problem where it will append to the bottom of files instead of overwriting them.
      It is recommended that you delete your file before compiling.

      I apologize for the inconvenience - Centurion
    END
    return
  end

  puts "Perfect! Your new file is named #{output_file}."
end

case command
when "transpile", "render", "digest" then orchestrate(file_given, output_language)
when "lex"                           then onlyLex(file_given)
when "parse"                         then onlyParse(file_given, output_language)

end




