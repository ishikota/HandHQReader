require 'spec_helper'

describe Showdown do
  include RoundReadHelper

  let(:src) do
    [
      "*** SHOW DOWN ***",
      "OlTk5/LshpUogB6dcoy9cw - Does not show",
      "OlTk5/LshpUogB6dcoy9cw Collects $0.75 from main pot",
      "eHofx78bgRviEqR2O9Mq5A - Mucks",
      "Rvos7NK8GCLECvED/BE4kA - Shows [7d As] (One pair, aces)"
    ]
  end

  it "should setup" do
    results = Showdown.new(src).results
    expect(results.size).to eq 4
    check(results[0], "OlTk5/LshpUogB6dcoy9cw", Showdown::Result::DOES_NOT_SHOW, nil)
    check(results[1], "OlTk5/LshpUogB6dcoy9cw", Showdown::Result::COLLECT_CHIP, 0.75)
    check(results[2], "eHofx78bgRviEqR2O9Mq5A", Showdown::Result::MUCK, nil)
    check(results[3], "Rvos7NK8GCLECvED/BE4kA", Showdown::Result::SHOWS,
          {"hole" => ["7d", "As"], "hand" => "One pair", "strength" => "aces"})
  end


  private

    def check(showdown, player_id, type, result)
      expect(showdown.player_id).to eq player_id
      expect(showdown.result_type).to eq type
      expect(showdown.result).to eq result
    end

end
