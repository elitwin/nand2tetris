require 'minitest/autorun'
require 'minitest/pride'
require_relative 'code'

class TestCode < MiniTest::Test
  def test_that_dest_translates_properly
    assert_equal '000', Code.dest(nil)
    assert_equal '001', Code.dest('M')
    assert_equal '010', Code.dest('D')
    assert_equal '011', Code.dest('MD')
    assert_equal '100', Code.dest('A')
    assert_equal '101', Code.dest('AM')
    assert_equal '110', Code.dest('AD')
    assert_equal '111', Code.dest('AMD')

    assert_equal 'invalid dest code',
    assert_raises(ArgumentError){ Code.dest('XYZ')}.message
  end

  def test_that_comp_translates_properly
    # Checking all 28 logic possibilities
    # actually 34 code possibilities - e.g. A+D and D+A should both work
    assert_equal '0101010', Code.comp('0')
    assert_equal '0111111', Code.comp('1')
    assert_equal '0111010', Code.comp('-1')
    assert_equal '0001100', Code.comp('D')
    assert_equal '0110000', Code.comp('A')
    assert_equal '1110000', Code.comp('M')
    assert_equal '0001101', Code.comp('!D')
    assert_equal '0110001', Code.comp('!A')
    assert_equal '1110001', Code.comp('!M')
    assert_equal '0001111', Code.comp('-D')
    assert_equal '0110011', Code.comp('-A')
    assert_equal '1110011', Code.comp('-M')
    assert_equal '0011111', Code.comp('D+1')
    assert_equal '0110111', Code.comp('A+1')
    assert_equal '1110111', Code.comp('M+1')
    assert_equal '0001110', Code.comp('D-1')
    assert_equal '0110010', Code.comp('A-1')
    assert_equal '1110010', Code.comp('M-1')
    assert_equal '0000010', Code.comp('D+A')
    assert_equal '0000010', Code.comp('A+D')
    assert_equal '1000010', Code.comp('D+M')
    assert_equal '1000010', Code.comp('M+D')
    assert_equal '0010011', Code.comp('D-A')
    assert_equal '1010011', Code.comp('D-M')
    assert_equal '0000111', Code.comp('A-D')
    assert_equal '1000111', Code.comp('M-D')
    assert_equal '0000000', Code.comp('D&A')
    assert_equal '0000000', Code.comp('A&D')
    assert_equal '1000000', Code.comp('D&M')
    assert_equal '1000000', Code.comp('M&D')
    assert_equal '0010101', Code.comp('D|A')
    assert_equal '0010101', Code.comp('A|D')
    assert_equal '1010101', Code.comp('D|M')
    assert_equal '1010101', Code.comp('M|D')

    assert_equal 'invalid comp code',
    assert_raises(ArgumentError){ Code.comp('X+1')}.message

    assert_equal 'invalid comp code',
    assert_raises(ArgumentError){ Code.comp(nil)}.message
  end

  def test_that_jump_translates_properly
    assert_equal '000', Code.jump(nil)
    assert_equal '001', Code.jump('JGT')
    assert_equal '010', Code.jump('JEQ')
    assert_equal '011', Code.jump('JGE')
    assert_equal '100', Code.jump('JLT')
    assert_equal '101', Code.jump('JNE')
    assert_equal '110', Code.jump('JLE')
    assert_equal '111', Code.jump('JMP')

    assert_equal 'invalid jump code',
    assert_raises(ArgumentError){ Code.jump('XYZ')}.message
  end

  def test_that_code_generates_proper_c_instructions
    assert_equal '1110101010001000', Code.c_instruction('M', '0', nil)
    assert_equal '1111110000010000', Code.c_instruction('D', 'M', nil)
    assert_equal '1110001100000110', Code.c_instruction(nil, 'D', 'JLE')
    assert_equal '1111000010001000', Code.c_instruction('M', 'M+D', nil)
  end

  def test_that_code_generates_proper_a_instructions
    # RAM between 0 and 16383
    assert_equal '0000000000000000', Code.a_instruction(0)
    assert_equal '0000000000000001', Code.a_instruction(1)
    assert_equal '0011111111111111', Code.a_instruction(16383)
    assert_equal '0011111111111111', Code.a_instruction('16383')
    # Screen memory map between 16384 and 24576
    assert_equal '0100000000000000', Code.a_instruction(16384)
    assert_equal '0101111111111111', Code.a_instruction(24575)
    # Keyboard memory map at 24576
    assert_equal '0110000000000000', Code.a_instruction(24576)

    # Max constant value
    assert_equal '0111111111111111', Code.a_instruction(32767)

    assert_equal 'value > 32767',
    assert_raises(ArgumentError){ Code.a_instruction(32768)}.message

    assert_equal 'invalid parameter',
    assert_raises(ArgumentError){ Code.a_instruction(nil)}.message

    assert_equal 'invalid parameter',
    assert_raises(ArgumentError){ Code.a_instruction('')}.message

    assert_equal 'invalid parameter',
    assert_raises(ArgumentError){ Code.a_instruction('@123')}.message
  end
end
