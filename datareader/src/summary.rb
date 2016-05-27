require 'pry'
class Summary
  attr :pot, :rake, :jackpot_rake, :board, :seat_results

  def initialize(lines)
    _head = lines.shift
    pot_line = lines.shift
    board_line = lines.shift if board_line?(lines.first)
    @pot, @rake, @jackpot_rake = read_pot(pot_line)
    @board = read_board(board_line)
    @seat_results = lines.reduce([]) { |acc, line| acc << Result.new(line) }
  end

  def read_pot(line)
    pot = line.match(/Total Pot\(\$([\d\.,]+)\).*/)[1].gsub(/,/,"").to_f
    rake = line.match(/Rake \(\$([\d\.,]+)\)/)
    jackpot_rake = line.match(/Jackpot Rake \(\$([\d\.,]+)\)/)
    rake = rake.nil? ? 0 : rake[1].gsub(",","").to_f
    jackpot_rake = jackpot_rake.nil? ? 0 : jackpot_rake[1].gsub(",","").to_f
    [pot, rake, jackpot_rake]
  end

  def read_board(line)
    if line.nil?
      []
    else
      line.match(/^Board \[(.*)\]/)[1].split
    end
  end

  def board_line?(line)
    line.match(/^Board/)
  end

  class Result
    attr :position, :player_id, :role, :type, :detail

    # ROLE flg
    NORMAL = 0
    SMALLBLIND = 1
    BIGBLIND = 2

    # DETAIL flg
    COLLECT = 0
    FOLD = 1
    WON = 2
    MUCK = 3
    LOST = 4

    def initialize(src)
      md = src.match(/Seat ([\d]+): (.*?) (.*)/)
      @position = md[1].to_i
      @player_id = md[2]
      @role = read_role(src)
      @type, @detail = read_detail(src)
    end

    def read_role(src)
      if src.match(/\(small blind\)/)
        SMALLBLIND
      elsif src.match(/\(big blind\)/)
        BIGBLIND
      else
        NORMAL
      end
    end

    def read_detail(src)
      if md = src.match(/ collected Total \(\$([\d\.,]+)\)/)
        [ COLLECT, { "amount" => md[1].gsub(",","").to_f } ]
      elsif md = src.match(/Folded on the (.*)/)
        [ FOLD, { "street" => md[1] } ]
      elsif md = src.match(/ won Total \(\$([\d\.,]+)\) .* with (.*?),(.*)/)
        [ WON, { "amount" => md[1].gsub(",","").to_f, "hand" => md[2], "detail" => md[3] } ]
      elsif md = src.match(/\[Mucked\] \[(.*)\]/)
        [ MUCK, { "hole" => md[1].split } ]
      elsif src.match(/lost with/)
        md = src.match(/with (.*?), (.*)/)
        hand = md.nil? ? "High card" : md[1]
        detail = md.nil? ? src.match(/with (.*)/)[1] : md[2]
        [ LOST, { "hand" => hand, "detail" => detail } ]
      else
        raise "received unexpected detail #{src}"
      end
    end

  end

end

