require 'minitest/autorun'
require 'minitest/pride'
require_relative 'symbol_table'

class TestSymbolTable < MiniTest::Test
  def test_that_it_initializes_properly
    st = SymbolTable.new

    # 5 predefined pointers, 16 virtual registers, 2 I/O pointers
    assert_equal 5 + 16 + 2, st.count

    # test all 5 predefined pointers
    assert_equal 0, st.get_address('SP')
    assert_equal 1, st.get_address('LCL')
    assert_equal 2, st.get_address('ARG')
    assert_equal 3, st.get_address('THIS')
    assert_equal 4, st.get_address('THAT')
    # test a few registers
    assert_equal 0, st.get_address('R0')
    assert_equal 15, st.get_address('R15')
    assert_nil st.get_address('R16')
    # test both I/O pointers
    assert_equal 16384, st.get_address('SCREEN')
    assert_equal 24576, st.get_address('KBD')
  end

  def test_that_it_handles_variables_properly
    st = SymbolTable.new

    st.add_entry 'counter'
    assert_equal 16, st.get_address('counter')
    st.add_entry 'sum'
    assert_equal 17, st.get_address('sum')
    # Adding duplicate entry should not change address
    st.add_entry 'counter'
    assert_equal 16, st.get_address('counter')

    # Does not add constants
    st.add_entry '0'
    assert_nil st.get_address('0')

    st.add_entry 123
    assert_nil st.get_address(123)
  end

  def test_that_it_handles_labels_properly
    st = SymbolTable.new

    st.add_entry('START', 0)
    assert_equal 0, st.get_address('START')

    st.add_entry('LOOP', 15)
    assert_equal 15, st.get_address('LOOP')

    st.add_entry('BEGIN', 196)
    assert_equal 196, st.get_address('BEGIN')

    # Adding label with different value should not change it
    st.add_entry('LOOP', 1)
    assert_equal 15, st.get_address('LOOP')

    st.add_entry('MAX', 32767)
    assert_equal 32767, st.get_address('MAX')

    # Negative address
    assert_equal 'invalid address',
    assert_raises(ArgumentError){ st.add_entry('NEG', -1)}.message

    # Overflow address
    assert_equal 'invalid address',
    assert_raises(ArgumentError){ st.add_entry('OVER', 32768)}.message
  end
end
