# frozen_string_literal: true

require_relative 'parser'
require_relative 'code'
require_relative 'symbol_table'

# Drives assembly process
class Assembler
  def initialize(file_path)
    dir_path = File.dirname(file_path)
    file_name = File.basename(file_path, '.asm')

    @out_file = File.open("#{dir_path}/#{file_name}.hack", 'w')
    @parser = Parser.new(file_path)
    @encoder = Code.new
    @symbol_table = SymbolTable.new
  end

  def self.assemble(file_path)
    new(file_path).assemble
  end

  def assemble
    first_pass
    @parser.reset
    second_pass
  end

  private

  def first_pass
    line_number = 0

    while @parser.more_lines?
      @parser.advance

      if @parser.instruction_type == :L_INSTRUCTION
        @symbol_table.add_entry(@parser.symbol, line_number)
        next
      end

      line_number += 1
    end
  end

  def second_pass
    while @parser.more_lines?
      @parser.advance

      case @parser.instruction_type
      when :A_INSTRUCTION
        @out_file.puts(encode_a_instruction)
      when :C_INSTRUCTION
        @out_file.puts(encode_c_instruction)
      end
    end
  end

  def encode_a_instruction
    symbol = @parser.symbol

    symbol = if @symbol_table.contains?(symbol)
               @symbol_table.get_address(symbol)
             else
               symbol.to_i
             end

    bin_val = symbol.to_s(2)
    zeroes = '0' * (15 - bin_val.length)

    "0#{format('%<fill>s%<binary>s', fill: zeroes, binary: bin_val)}"
  end

  def encode_c_instruction
    comp = @encoder.comp(@parser.comp)
    dest = @encoder.dest(@parser.dest)
    jump = @encoder.jump(@parser.jump)

    "111#{comp}#{dest}#{jump}"
  end
end

if $PROGRAM_NAME == __FILE__
  unless ARGV.length == 1 && ARGV[0].end_with?('.asm')
    puts 'Usage: assembler.rb FILE_PATH.asm'
    return
  end

  unless File.exist?(ARGV[0])
    puts "Error: #{ARGV[0]} does not exist."
    return
  end

  Assembler.assemble(ARGV[0])
end
