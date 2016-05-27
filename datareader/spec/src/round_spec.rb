require 'spec_helper'
require 'date'

describe Round do
  let(:round) { Round.new }

  let(:src) do
    f = File.open(fname)
    src = f.read
    f.close
    src.split("\n")
  end

  describe "basic info" do
    let(:fname) { "spec/data/sitout_round_src.txt" }

    it "should setup" do
      round.read_src(src)
      expect(round.round_id).to eq "3064273616"
      expect(round.rule).to eq "Holdem  No Limit"
      expect(round.blind).to eq 0.5
      expect(round.play_time).to eq DateTime.new(2009, 7, 14, 11, 53, 11)
      expect(round.table.name).to eq "LEOPARD DR"
      expect(round.table.players.size).to eq 8
      expect(round.force_pay.size).to eq 2
      expect(round.showdown.results.size).to eq  2
      expect(round.summary.seat_results.size).to eq 7
    end
  end

  describe "street info" do
    let(:fname) { "spec/data/whole_round_src.txt" }

    it "should setup" do
      round.read_src(src)
      expect(round.streets.size).to eq 4
      expect(round.streets[0].name).to eq "POCKET CARDS"
      expect(round.streets[1].name).to eq "FLOP"
      expect(round.streets[2].name).to eq "TURN"
      expect(round.streets[3].name).to eq "RIVER"
    end
  end

end
