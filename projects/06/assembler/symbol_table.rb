class SymbolTable
  def initialize
    @syms = Hash.new
    @mem = 16 # first user-defined memory address location
    init_table
  end

  # Is this needed anywhere?
  def contains?(symbol)
    @syms.has_key?(symbol)
  end

  def get_address(symbol)
    @syms[symbol]
  end

  def count
    @syms.length
  end

  def add_entry(symbol, address=nil)
    # Perhaps add command_type as a parameter
    return if @syms.has_key?(symbol)
    return if symbol.to_s =~ /^\d/

    if address
      raise ArgumentError, 'invalid address' unless
        address >= 0 && address <= 32767
      @syms[symbol] = address
    # Add a_instruction if not a constant (doesn't start with a digit)
    else
      @syms[symbol] = @mem
      @mem += 1
    end
  end

private
  def init_table
    # Add predefined pointers
    @syms['SP'] = 0
    @syms['LCL'] = 1
    @syms['ARG'] = 2
    @syms['THIS'] = 3
    @syms['THAT'] = 4
    # Add virtual registers
    (0..15).each {|i| @syms['R'+i.to_s] = i }
    # Add I/O pointers
    @syms['SCREEN'] = 16384
    @syms['KBD'] = 24576
  end
end
