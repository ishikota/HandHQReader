class Action
  attr :player_id, :action, :bet_amount, :add_amount

  ANTE = 0
  SMALL_BLIND = 1
  BIG_BLIND = 2
  FOLD = 3
  CHECK = 4
  CALL = 5
  RAISE = 6
  BET = 7
  ALLIN = 8

  def initialize(src)
    if md = src.match(/(.*?) - Ante (.*?)\$([\d\.,]*)/)
      @player_id = md[1]
      @action = ANTE
      @bet_amount = md[md.size-1].gsub(",","").to_f
      @add_amount = 0
    elsif md = src.match(/(.*?) - Posts (.*?) blind \$([\d\.,]*) */)
      @player_id = md[1]
      @action = md[2] == "small" ? SMALL_BLIND : BIG_BLIND
      @bet_amount = md[3].gsub(",","").to_f
      @add_amount = md[2] == "small" ? @bet_amount : @bet_amount/2
    elsif md = src.match(/(.*?) - Folds/)
      @player_id = md[1]
      @action = FOLD
      @bet_amount = 0
      @add_amount = 0
    elsif md = src.match(/(.*?) - Checks/)
      @player_id = md[1]
      @action = CHECK
      @bet_amount = 0
      @add_amount = 0
    elsif md = src.match(/(.*?) - Calls \$([\d\.,]*)/)
      @player_id = md[1]
      @action = CALL
      @bet_amount = md[2].gsub(",","").to_f
      @add_amount = 0
    elsif md = src.match(/(.*?) - Bets \$([\d\.,]*)/)
      @player_id = md[1]
      @action = BET
      @bet_amount = md[2].gsub(",","").to_f
      @add_amount = md[2].gsub(",","").to_f
    elsif md = src.match(/(.*?) - Raises \$([\d\.,]*) to \$([\d\.,]*)/)
      @player_id = md[1]
      @action = RAISE
      @bet_amount = md[3].gsub(",","").to_f
      @add_amount = @bet_amount - md[2].gsub(",","").to_f
    elsif md = src.match(/(.*?) - All-In \$([\d\.,]*)/)
      @player_id = md[1]
      @action = ALLIN
      @bet_amount = md[2].gsub(",","").to_f
      @add_amount = 0
    elsif md = src.match(/(.*?) - All-In\(Raise\) \$([\d\.,]*) to \$([\d\.,]*)/)
      @player_id = md[1]
      @action = ALLIN
      @bet_amount = md[2].gsub(",","").to_f
      @add_amount = md[3].gsub(",","").to_f
    elsif md = src.match(/(.*?) - returned \(\$([\d\.,]*)\)/)
      # do nothing
    else
      raise "Received unexpected action : #{src}"
    end
  end
end

