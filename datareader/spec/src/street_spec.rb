require 'spec_helper'

describe Street do
  include RoundReadHelper

  let(:hash) do
    f = File.open("spec/data/whole_round_src.txt")
    src = f.read
    f.close
    separate_by_street(src.split("\n"))
  end

  context "PREFLOP" do
    it "should setup" do
      street = Street.new(hash[Round::POCKET_CARDS])
      expect(street.actions.first.player_id).to eq "wFNV0TSwysA+SPvQBPZ+qA"
      expect(street.actions.size).to eq 6
      expect(street.community_card).to be_empty
    end
  end

  context "FLOP" do
    it "should setup" do
      street = Street.new(hash[Round::FLOP])
      expect(street.community_card).to eq ["10d", "Kh", "3h"]
    end
  end

  context "TURN" do
    it "should setup" do
      street = Street.new(hash[Round::TURN])
      expect(street.community_card).to eq ["10d", "Kh", "3h", "5s"]
    end
  end

  context "RIVER" do
    it "should setup" do
      street = Street.new(hash[Round::TURN])
      expect(street.community_card).to eq ["10d", "Kh", "3h", "5s"]
    end
  end

end
