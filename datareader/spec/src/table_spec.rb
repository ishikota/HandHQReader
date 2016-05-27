require 'spec_helper'

describe Table do
  let(:src) {
    "Table: CLEO AVE (Real Money) Seat #2 is the dealer"
  }

  it "should setup" do
    tb = Table.new(src)
    expect(tb.name).to eq "CLEO AVE"
    expect(tb.dealer_position).to eq 2
    expect(tb.players).to be_empty
  end
end
