require_relative 'code'

class Parser
  attr_reader :current_command # primarily for testing purposes
  attr_reader :command_type, :symbol, :dest, :comp, :jump

  def initialize(source)
    @source = source
    raise "Invalid source - cannot be nil or 0 length" unless
      source && source.length > 0
    @current_command = nil
  end

  def has_more_commands?
    !@source.eof?
  end

  def advance
    begin
      @current_command = @source.gets.gsub(/(\/\/.*$)/, '').gsub(/\s+/,'')
      @command_type, @symbol, @dest, @comp, @jump = nil
    end while @current_command.empty?

    process_command if @current_command
  end

  def rewind
    @source.rewind if @source
  end

private
  def process_command
    case @current_command
    when /^(@[a-zA-z:$\.]+[a-zA-z:\$\.0-9]*|@\d+[\D]{0})$/
      @command_type = :a_command
      @symbol = $1.gsub(/^@/,'')
    when /^(\({1}.*\){1})$/
      @command_type = :l_command
      @symbol = $1.gsub(/^\(/,'').gsub(/\)$/,'')
    when /^(?:([AMD]+)=)?([!]?[AMD]?[+\-&\|]?[\dAMD])(?:;(\w{3}))?$/
      @dest, @comp, @jump = $~.captures
      @command_type = :c_command
    end

    # Note - jump with computation is supported, e.g. D+1;JLE - is this correct?

    # Most if not all of these raise errors could be eliminated with a lot
    # better regex - splitting dest=comp and comp;jmp into two separate
    # regex matches would probably make it much easier to handle
    # Then we would only need the first raise error when @command_type is nil
    raise ArgumentError, 'unknown command/invalid label' if
      @command_type.nil?
    raise ArgumentError, 'invalid c_command - jump with assignment' if
      @dest && @comp && @jump
    raise ArgumentError, 'invalid c_command - comp with no dest or jump' if
      !@dest && @comp && !@jump
    raise ArgumentError, 'invalid c_command - jump referencing M' if
      @jump && @comp && @comp.include?('M')
    raise ArgumentError, 'invalid c_command - bad dest' if
      @dest && !Code::DEST.has_key?(@dest)
    raise ArgumentError, 'invalid c_command - bad comp' if
      @comp && !Code::COMP.has_key?(@comp)
    raise ArgumentError, 'invalid c_command - bad jump' if
      @jump && !Code::JUMP.has_key?(@jump)

    # current c_command regex never triggers this situation
    #raise ArgumentError, 'invalid c_command - dest with no comp' if
    #  @dest && !@comp  # Destination with no Computation
  end
end
