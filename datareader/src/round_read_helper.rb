module RoundReadHelper

  def separate_by_street(src)
    status = Round::ROUND_INFO
    hash = (0..6).reduce({}) { |acc, i| acc.merge({ i => [] }) }
    src.each { |line|
      status = increment_status_if_needed(status, line)
      hash[status] << line
    }
    hash
  end

  def increment_status_if_needed(status, line)
    if line.match(/\* POCKET CARDS \*/)
      Round::POCKET_CARDS
    elsif line.match(/\* FLOP \*/)
      Round::FLOP
    elsif line.match(/\* TURN \*/)
      Round::TURN
    elsif line.match(/\* RIVER \*/)
      Round::RIVER
    elsif line.match(/\* SHOW DOWN \*/)
      Round::SHOWDOWN
    elsif line.match(/\* SUMMARY \*/)
      Round::SUMMARY
    else
      status
    end
  end

end
