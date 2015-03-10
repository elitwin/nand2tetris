class Code
  DEST = {
    nil   => '000',
    'M'   => '001',
    'D'   => '010',
    'MD'  => '011',
    'A'   => '100',
    'AM'  => '101',
    'AD'  => '110',
    'AMD' => '111',
  }

  COMP = {
    '0'   => '0101010',
    '1'   => '0111111',
    '-1'  => '0111010',
    'D'   => '0001100',
    'A'   => '0110000',
    'M'   => '1110000',
    '!D'  => '0001101',
    '!A'  => '0110001',
    '!M'  => '1110001',
    '-D'  => '0001111',
    '-A'  => '0110011',
    '-M'  => '1110011',
    'D+1' => '0011111',
    'A+1' => '0110111',
    'M+1' => '1110111',
    'D-1' => '0001110',
    'A-1' => '0110010',
    'M-1' => '1110010',
    'D+A' => '0000010',
    'A+D' => '0000010',
    'D+M' => '1000010',
    'M+D' => '1000010',
    'D-A' => '0010011',
    'D-M' => '1010011',
    'A-D' => '0000111',
    'M-D' => '1000111',
    'D&A' => '0000000',
    'A&D' => '0000000',
    'D&M' => '1000000',
    'M&D' => '1000000',
    'D|A' => '0010101',
    'A|D' => '0010101',
    'D|M' => '1010101',
    'M|D' => '1010101'
  }

  JUMP = {
    nil   => '000',
    'JGT' => '001',
    'JEQ' => '010',
    'JGE' => '011',
    'JLT' => '100',
    'JNE' => '101',
    'JLE' => '110',
    'JMP' => '111'
  }

  def self.dest(key)
    raise ArgumentError, 'invalid dest code' unless DEST.has_key?(key)
    DEST[key]
  end

  def self.comp(key)
    raise ArgumentError, 'invalid comp code' unless COMP.has_key?(key)
    COMP[key]
  end

  def self.jump(key)
    raise ArgumentError, 'invalid jump code' unless JUMP.has_key?(key)
    JUMP[key]
  end

  def self.a_instruction(sym)
    raise ArgumentError, 'invalid parameter' if
      sym.to_s.empty? || sym.to_s.start_with?('@')
    raise ArgumentError, 'value > 32767' if sym.to_i > 32767
    # convert s to binary - prepend with 0's up to 15
    ['0', '%015b' % sym].join
  end

  def self.c_instruction(d, c, j)
    raise ArgumentError, 'invalid parameters' if
      !d && !c && !j # no parameter data

    ['111', comp(c), dest(d), jump(j)].join
  end
end
