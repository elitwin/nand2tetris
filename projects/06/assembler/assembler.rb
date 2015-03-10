require 'stringio'
require_relative 'parser'
require_relative 'code'
require_relative 'symbol_table'

class Assembler
  def self.process_file(filename)
    raise ArgumentError, 'file does not exist' unless File.exists?(filename)
    raise ArgumentError, 'not .asm file' unless filename.end_with?('.asm')

    puts "Processing file '#{filename}'"
    parser = Parser.new StringIO.new File.open(filename, 'r').read

    puts "First pass - generate labels"
    symbol_table = generate_labels parser

    puts "Second pass - generate commands"
    parser.rewind
    o = generate_commands parser, symbol_table

    filename_out = filename.gsub(/asm$/, 'hack')
    File.open(filename_out, "w") { |f|
      f.write o.join("\n") + "\n" # add ending newline
      f.close
    }
    puts "Output saved to '#{filename_out}'"
  end

private
  def self.generate_labels(p)
    st = SymbolTable.new
    line_no = 0

    while p.has_more_commands? do
      p.advance

      case p.command_type
      when :l_command
        # don't increment line counter on labels
        st.add_entry p.symbol, line_no
      else :c_command
        line_no += 1
      end
    end
    st
  end

  def self.generate_commands(p, st)
    o = [] # for storing output

    while p.has_more_commands? do
      p.advance
      case p.command_type
      when :a_command
        st.add_entry p.symbol
        o << Code.a_instruction(st.get_address(p.symbol) || p.symbol)
      when :c_command
        o << Code.c_instruction(p.dest, p.comp, p.jump)
      end
    end

    o
  end
end

Assembler.process_file ARGV[0]
