require 'spec_helper'

describe Player do
  let(:src) {
    "Seat 5 - T3thDbHTsVbuaHli6S6CwA ($38.50 in chips)"
  }

  it "should setup" do
    player = Player.new(src)
    expect(player.player_id).to eq "T3thDbHTsVbuaHli6S6CwA"
    expect(player.seat_position).to eq 5
    expect(player.stack).to eq 38.50
    expect(player.status).to be_nil
  end
end
