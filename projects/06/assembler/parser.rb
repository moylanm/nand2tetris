# frozen_string_literal: true

# Parses .asm files
class Parser
  def initialize(file_path)
    @file = File.open(file_path, 'r')
    @curr_inst = nil
  end

  def more_lines?
    !@file.eof?
  end

  def advance
    tmp = nil

    loop do
      tmp = @file.readline.strip # sanitize line (remove \r\n)

      next if tmp.start_with?('//') || tmp == ''

      break
    end

    @curr_inst = tmp.split[0] # some instruction lines have comments
  end

  def reset
    @file.rewind
    @curr_inst = nil
  end

  def instruction_type
    return :A_INSTRUCTION if @curr_inst.start_with?('@')

    return :L_INSTRUCTION if @curr_inst.start_with?('(')

    :C_INSTRUCTION
  end

  def symbol
    return @curr_inst[1..@curr_inst.length] if @curr_inst.start_with?('@')

    return @curr_inst[1..@curr_inst.length - 2] if @curr_inst.start_with?('(')
  end

  def dest
    @curr_inst.split('=')[0] if @curr_inst.include?('=')
  end

  def comp
    return @curr_inst.split('=')[1] if @curr_inst.include?('=')

    return @curr_inst.split(';')[0] if @curr_inst.include?(';')
  end

  def jump
    @curr_inst.split(';')[1] if @curr_inst.include?(';')
  end
end
