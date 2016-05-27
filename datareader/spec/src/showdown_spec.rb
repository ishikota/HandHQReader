require 'spec_helper'

describe Showdown do
  include RoundReadHelper

  let(:src) do
    [
      "*** SHOW DOWN ***",
      "OlTk5/LshpUogB6dcoy9cw - Does not show",
      "OlTk5/LshpUogB6dcoy9cw Collects $0.75 from main pot",
      "eHofx78bgRviEqR2O9Mq5A - Mucks",
      "Rvos7NK8GCLECvED/BE4kA - Shows [7d As] (One pair, aces)",
      "885LXMD+qICcd15BFMNvEg - Shows [8h 7d] (ace high)"
    ]
  end

  it "should setup" do
    results = Showdown.new(src).results
    expect(results.size).to eq 5
    check(results[0], "OlTk5/LshpUogB6dcoy9cw", Showdown::Result::DOES_NOT_SHOW, nil)
    check(results[1], "OlTk5/LshpUogB6dcoy9cw", Showdown::Result::COLLECT_CHIP, 0.75)
    check(results[2], "eHofx78bgRviEqR2O9Mq5A", Showdown::Result::MUCK, nil)
    check(results[3], "Rvos7NK8GCLECvED/BE4kA", Showdown::Result::SHOWS,
          {"hole" => ["7d", "As"], "hand" => "One pair", "strength" => "aces"})
    check(results[4], "885LXMD+qICcd15BFMNvEg", Showdown::Result::SHOWS,
          {"hole" => ["8h", "7d"], "hand" => "High card", "strength" => "ace high"})
  end


  private

    def check(showdown, player_id, type, result)
      expect(showdown.player_id).to eq player_id
      expect(showdown.result_type).to eq type
      expect(showdown.result).to eq result
    end

end
