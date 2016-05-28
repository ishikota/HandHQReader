require 'date'
class Round
  include RoundReadHelper
  attr :round_id, :blind, :play_time, :rule, :force_pay, :table, :streets, :showdown, :summary

  ROUND_INFO = 0
  POCKET_CARDS = 1
  FLOP = 2
  TURN = 3
  RIVER = 4
  SHOWDOWN = 5
  SUMMARY = 6

  def initialize(src)
    @force_pay = []
    @streets = []
    read_src(src)
  end

  def read_src(src)
    hash = separate_by_street(src)
    read_round_info(hash[ROUND_INFO])
    @streets << Street.new(hash[POCKET_CARDS])
    @streets << Street.new(hash[FLOP]) unless hash[FLOP].empty?
    @streets << Street.new(hash[TURN]) unless hash[TURN].empty?
    @streets << Street.new(hash[RIVER]) unless hash[RIVER].empty?
    @showdown = Showdown.new(hash[SHOWDOWN])
    @summary = Summary.new(hash[SUMMARY])
  end

  def read_round_info(src)
    src.each { |line|
      if line.match(/^Stage/)
        set_stage_info(line)
      elsif line.match(/^Table:/)
        @table = Table.new(line)
      elsif line.match(/^Seat /)
        @table.players << Player.new(line)
      elsif line.match(/Posts .*? blind/) || line.match(/ Ante /)
        @force_pay << Action.new(line)
      elsif line.match(/Posts .*?/)
        # Posts $5
      elsif line.match(/ sitout /) or line.match(/sit out/) or line.match(/leave/)
        # TODO handle
      else
        raise "Received unexpected round info : #{line}"
      end
    }
  end

  def set_stage_info(line)
    md = line.match(/Stage #([\d]*): ([\w\s\d\(\)]*) \$([\d\.,]*)/)
    @round_id = md[1]
    @rule = md[2]
    @blind = md[3].gsub(",","").to_f
    md = line.match(/ - (\d{4})-(\d{2})-(\d{2}) (\d{2}:\d{2}:\d{2})/)
    y = md[1].to_i
    m = md[2].to_i
    d = md[3].to_i
    h, mi, s = md[4].split(":").map(&:to_i)

    @play_time = DateTime.new(y, m, d, h, mi, s)
  end

end
