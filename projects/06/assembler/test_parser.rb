require 'minitest/autorun'
require 'minitest/pride'
require_relative 'parser'

class TestParser < MiniTest::Test
  # No symbols/comments
  SOURCE =<<EOF
    @2
    D=A
    @3
    D=D+A
    @0
    M=D
    D=!M
    @456
    D=D&M
    D=D&A
    A=D|M
    A=1
    A=0
    D=-1
    A=!D
    AD=-M
    D=-D
    A=-M
EOF

  # Symbols, Comments, whitespace
  SOURCE_L =<<EOF
    // Beginning comment followed by empty line

    @R0
    D=M              // D = first number
    @R1
    D=D-M            // D = first number - second number
    @OUTPUT_FIRST
    D;JGT            // if D>0 (first is greater) goto output_first
    @R1
    D=M              // D = second number
    @OUTPUT_D
    0;JMP            // goto output_d
 (OUTPUT_FIRST)
    @R0
    D=M              // D = first number
 (OUTPUT_D)
    @R2
    M=D              // M[2] = D (greatest number)
 (INFINITE_LOOP)
    @INFINITE_LOOP
    0;JMP            // infinite loop
EOF

  def test_that_parser_implements_has_more_commands
    p = Parser.new StringIO.new SOURCE
    assert p.has_more_commands?, 'Should have more commands'
  end

  def do_parse(source)
    p = Parser.new StringIO.new source
    while p.has_more_commands? do
      p.advance
      ct = p.command_type
      refute_nil p.symbol if
        [:a_command, :l_command].include? ct
      assert_nil p.symbol if ct == :c_command
      refute_nil p.comp if ct == :c_command
      # Can't have both jump and dest set
      assert_nil p.dest if ct == :c_command && p.jump
      assert_nil p.jump if ct == :c_command && p.dest
    end
    refute p.has_more_commands?, 'Should have no more commands'
  end

  def test_that_parser_can_handle_code_without_labels
    do_parse SOURCE
  end

  def test_that_parser_can_handle_code_with_labels
    do_parse SOURCE_L
  end

  def test_that_parser_can_determine_command_type
    # A command, L command, C Command (dest=comp), C Command (comp;JMP)
    p = Parser.new StringIO.new "@1\n(LOOP)\nD=D+1\nD;JMP\n@5"
    assert_nil p.current_command

    p.advance # @1
    assert_equal :a_command, p.command_type
    assert_equal '1', p.symbol

    p.advance # (LOOP)
    assert_equal :l_command, p.command_type
    assert_equal 'LOOP', p.symbol

    p.advance # D=D+1
    assert_equal :c_command, p.command_type
    assert_nil p.symbol
    assert_equal 'D', p.dest
    assert_equal 'D+1', p.comp
    assert_nil p.jump

    p.advance # D;JMP
    assert_equal :c_command, p.command_type
    assert_nil p.symbol
    assert_nil p.dest
    assert_equal 'D', p.comp
    assert_equal 'JMP', p.jump

    p.advance # @5
    assert_equal :a_command, p.command_type
    assert_equal '5', p.symbol
    assert_nil p.dest
    assert_nil p.comp
    assert_nil p.jump
  end

  def test_that_parser_ignores_whitespace
    p = Parser.new StringIO.new "   \n\n  (LOOP)  \n  M D = D + 1"

    assert_nil p.current_command
    assert_nil p.symbol
    assert_nil p.dest
    assert_nil p.comp
    assert_nil p.jump

    # ignores line with empty spaces
    # ignores line with no spaces
    # ignores space before and after label
    p.advance
    assert_equal 'LOOP', p.symbol

    # ignores space between commands, e.g. M D = D + 1 is same as MD=D+1
    p.advance # M D = D + 1
    assert_equal :c_command, p.command_type
    assert_equal 'MD', p.dest
    assert_equal 'D+1', p.comp
    assert_nil p.jump
  end

  def test_that_parser_ignores_comments
    source=<<EOF
      // comment only line (with leading whitespace too)
    @1 // a_command comment
    (LOOP) // l_command comment
    0;JMP // c_command comment
EOF
    p = Parser.new StringIO.new source

    # Comment line automatically ignored

    # Handle a-instruction with end of line comment
    p.advance
    assert_equal :a_command, p.command_type
    assert_equal '1', p.symbol

    # Handle label command with end of line comment
    p.advance
    assert_equal :l_command, p.command_type
    assert_equal 'LOOP', p.symbol

    # Handle c-instruction with end of line comment
    p.advance
    assert_equal :c_command, p.command_type
    assert_equal '0', p.comp
    assert_equal 'JMP', p.jump
  end

  def test_that_parser_handles_bad_code
  # Bad assembly commands
  source=<<EOF
  @         // invalid symbol
  @-1       // Negative A-value
  @5-3      // bad symbol
  xyz       // unknown command
  0;JMB     // unknown jump type
  D=M;JMP   // mixing jump with assignment
  M;JMP     // jump references M
(TEST       // unclosed label
(TEST)abc   // invalid characters after label
  D;        // computation with no jump (invalid syntax)
  D         // destination with no computation
  D+1       // computation with no destination
  D=D+2     // invalid constant
  D=M-0     // invalid constant
  D=+1      // invalid assignment
  DA=D+1    // invalid ordering of dest (must be AMD)
EOF

    p = Parser.new StringIO.new source

    assert_equal 'unknown command/invalid label', # @
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # @-1
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # @5-3
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # xyz
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - bad jump', # 0;JMB
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - jump with assignment', # D=M;JMP
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - jump referencing M', # M;JMP
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # (TEST
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # (TEST)abc
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'unknown command/invalid label', # D;
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - comp with no dest or jump', # D
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - comp with no dest or jump', # D+1
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - bad comp', # D=D+2
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - bad comp', # D=M-0
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - bad comp', # D=+1
    assert_raises(ArgumentError){ p.advance }.message

    assert_equal 'invalid c_command - bad dest', # DA=D+1
    assert_raises(ArgumentError){ p.advance }.message

    refute p.has_more_commands? # Make sure we tested all cases
  end
end
