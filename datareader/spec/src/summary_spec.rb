require 'spec_helper'

describe Summary do

  context "without board" do
    let(:lines) do
      [
        "*** SUMMARY ***",
        "Total Pot($0.75)",
        "Seat 4: vpE5Ux191EYMxT2GPzpK+A (big blind) collected Total ($0.75)",
        "Seat 6: 8utzZeaKgkpt8ofv9hqBFg (dealer) (small blind) Folded on the POCKET CARDS",
        "Seat 5: 5zM5FjH98SuwRV3RIhkzMg won Total ($42.46) HI:($42.46) with Two Pair, kings and queens [Qd 10h - B:Ks,B:Kh,B:Qh,P:Qd,B:Jh]",
        "Seat 4: 8cmqBf8pFS0aWT5uWUZG1A HI: [Mucked] [9h 6c]",
        "Seat 2: wFNV0TSwysA+SPvQBPZ+qA HI:lost with Flush, ace high [Qd 10d - B:Ad,P:Qd,P:10d,B:8d,B:7d]"
      ]
    end

    let(:seat_ans) do
      [
        [4, "vpE5Ux191EYMxT2GPzpK+A", Summary::Result::BIGBLIND, Summary::Result::COLLECT,
          { "amount" => 0.75 }
        ],
        [6, "8utzZeaKgkpt8ofv9hqBFg", Summary::Result::SMALLBLIND, Summary::Result::FOLD,
          { "street" => "POCKET CARDS" }
        ],
        [5, "5zM5FjH98SuwRV3RIhkzMg", Summary::Result::NORMAL, Summary::Result::WON,
          { "amount" => 42.46, "hand" => "Two Pair", "detail" => anything }
        ],
        [4, "8cmqBf8pFS0aWT5uWUZG1A", Summary::Result::NORMAL, Summary::Result::MUCK,
          { "hole" => ["9h", "6c"] }
        ],
        [2, "wFNV0TSwysA+SPvQBPZ+qA", Summary::Result::NORMAL, Summary::Result::LOST,
          { "hand" => "Flush", "detail" => anything }
        ]
      ]
    end

    it "should setup" do
      summary = Summary.new(lines)
      results = summary.seat_results
      expect(summary.pot).to eq 0.75
      expect(summary.rake).to eq 0
      expect(summary.jackpot_rake).to eq 0
      expect(summary.board).to be_empty
      expect(results.size).to eq 5
      results.zip(seat_ans).each { |res, ans|
        check(res, ans[0], ans[1], ans[2], ans[3], ans[4])
      }
    end
  end

  private

    def check(result, position, player_id, role, type, detail)
      expect(result.position).to eq position
      expect(result.player_id).to eq player_id
      expect(result.role).to eq role
    end

end
