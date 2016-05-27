require 'spec_helper'

describe Action do
  let(:act) { Action.new(src) }

  describe "ante" do
    context "pattern1" do
      let(:src) {
        "eXXdS46B0E4apgZgp7gHFw - Ante $2.50"
      }
      
      it "should setup" do
        check(act, "eXXdS46B0E4apgZgp7gHFw", Action::ANTE, 2.5, 0)
      end
    end

    context "pattern2" do
      let(:src) {
        "eXXdS46B0E4apgZgp7gHFw - Ante returned $2.50"
      }
      
      it "should setup" do
        check(act, "eXXdS46B0E4apgZgp7gHFw", Action::ANTE, 2.5, 0)
      end
    end
  end

  describe "blind" do
    context "small blind" do
      let(:src) {
        "dZLpq1X1Bx/8a42WZCIPMg - Posts small blind $0.25"
      }

      it "should setup" do
        check(act, "dZLpq1X1Bx/8a42WZCIPMg", Action::SMALL_BLIND, 0.25, 0.25)
      end
    end

    context "big blind" do
      let(:src) {
        "O3s9IsmHGwUXmVX06sW5wA - Posts big blind $0.50"
      }

      it "should setup" do
        check(act, "O3s9IsmHGwUXmVX06sW5wA", Action::BIG_BLIND, 0.50, 0.25)
      end
    end
  end

  describe "allin" do
    context "pattern1" do
      let(:src) {
        "J4+irtFaN4tesOvvW9zmAQ - All-In $3.73"
      }

      it "should setup" do
        check(act, "J4+irtFaN4tesOvvW9zmAQ", Action::ALLIN, 3.73, 0)
      end
    end
    context "pattern2" do
      let(:src) {
        "c2tiA/SMUK+T0PsP2rCOGA - All-In(Raise) $1,024.75 to $1,024.75"
      }

      it "should setup" do
        check(act, "c2tiA/SMUK+T0PsP2rCOGA", Action::ALLIN, 1024.75, 1024.75)
      end
    end
  end

  private

    def check(act, player_id, action, bet_amount, add_amount)
      expect(act.player_id).to eq player_id
      expect(act.action).to eq action
      expect(act.bet_amount).to eq bet_amount
      expect(act.add_amount).to eq add_amount
    end

end
