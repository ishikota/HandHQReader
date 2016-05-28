require 'mysql2'

class DBWriter

  def initialize(host='localhost', username='root', password='', dbname='handhq')
    @client = Mysql2::Client.new(
      :host => host,
      :username => username,
      :password => password,
      :dbname => dbname
    )
  end

  def write_round_data(round)
    @client.query(query_insert_round(round))
    round.table.players.each { |player|
      @client.query(query_insert_playerinfo(round, player))
      @client.query(query_insert_round_playerinfo_relationship(round, player))
    }
    round.streets.each { |street|
      @client.query(query_insert_board)
      street.community_card.each { |card|
        @client.query(query_board_card_relation(card))
      }
      @client.query(query_insert_street(street))
      street.actions.select{ |a| a.action }.each { |action|
        insert(query_insert_action(action))
        @client.query(query_insert_street_action_relation)
      }
    }

    @client.query(query_insert_board)
    @client.query(query_insert_summary(round.summary))
    @client.query(query_inert_round_summary_relation(round.round_id))
    round.summary.board.each { |card|
      @client.query(query_board_card_relation(card))
    }
    round.summary.seat_results.each { |result|
      result_query = case result.type
      when 0 # collected
        query_insert_collect_result(result)
      when 1 # folded
        query_insert_folded_result(result)
      when 2 # won
        query_insert_won_result(result)
      when 3 # muck
        query_insert_muck_result(result)
      when 4 # lost
        query_insert_lost_result(result)
      end
      @client.query(query_insert_seat_result(result))
      @client.query(result_query)
    }
  end

  def query_insert_round(round)
    round_id = round.round_id
    p = round.play_time
    play_time = "#{p.year}-#{p.month}-#{p.day} #{p.hour}:#{p.minute}:#{p.second}"
    rule = round.rule
    blind = round.blind
    dealer = round.table.dealer_position
    table_name = round.table.name

    cols = ["round_id", "play_time", "rule", "blind", "dealer_position", "table_name"]
    vals = [round_id, play_time, rule, blind, dealer, table_name]
    query_smart_insert("round", cols, vals)
  end

  def query_insert_playerinfo(round, player)
    player_id = player.player_id
    seat_position = player.seat_position
    stack = player.stack
    role = fetch_player_role(round, player_id)

    cols = ["player_id", "seat_position", "stack", "role"]
    vals = [player_id, seat_position, stack, role]
    unless role
      cols.delete("role")
      vals.delete(role)
    end
    query_smart_insert("player_info", cols, vals)
  end

  def query_insert_round_playerinfo_relationship(round, player)
    round_id = "'#{round.round_id}'"
    player_info_id = "(SELECT MAX(id) FROM player_info WHERE player_id = '#{player.player_id}')"

    cols = ["round_id", "player_info_id"]
    vals = [round_id, player_info_id]
    query_naive_insert("round_playerinfo_relation", cols, vals)
  end

  def query_insert_board()
    query_naive_insert("board", [], [])
  end

  def query_board_card_relation(card)
    board_id = "(SELECT MAX(id) FROM board)"
    cols = ["board_id", "card_id"]
    vals = [board_id, card_to_id(card)]
    query_naive_insert("board_card_relation", cols, vals)
  end

  def card_to_id(card)
    suit_map = { "c" => 0, "d" => 1, "h" => 2, "s" => 3 } 
    rank_map = {
      "A" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7,
      "8" => 8, "9" => 9, "10" => 10, "J" => 11, "Q" => 12, "K" => 13
    }
    r = rank_map[card[0...-1]]
    s = suit_map[card[-1]]
    r + 13*s
  end

  def query_insert_street(street)
    type_map = { "POCKET CARDS" => 1, "FLOP" => 2, "TURN" => 3, "RIVER" => 4, "SHOWDOWN" => 5 }
    type = type_map[street.name]
    board_id = "(SELECT MAX(id) FROM board)"
    cols = ["type", "board_id"]
    vals = [type, board_id]
    query_naive_insert("street", cols, vals)
  end

  def query_insert_action(action)
    player_id = action.player_id
    type = action.action
    bet_amount = action.bet_amount
    add_amount = action.add_amount
    cols = ["player_id", "type", "bet_amount", "add_amount"]
    vals = [player_id, type, bet_amount, add_amount]
    query_smart_insert("action", cols, vals)
  end

  def query_insert_street_action_relation
    street_id = "(SELECT MAX(id) FROM street)"
    action_id = "(SELECT MAX(id) FROM action)"
    cols = ["street_id", "action_id"]
    vals = [street_id, action_id]
    query_naive_insert("street_action_relation", cols, vals)
  end

  def query_insert_summary(summary)
    pot = summary.pot
    rake = summary.rake
    jackpot_rake = summary.jackpot_rake
    board_id = "(SELECT MAX(id) FROM board)"
    cols = ["pot", "rake", "jackpot_rake", "board_id"]
    vals = [pot, rake, jackpot_rake, board_id]
    query_naive_insert("summary", cols, vals)
  end

  def query_inert_round_summary_relation(round_id)
    "UPDATE round SET summary_id=(SELECT MAX(id) FROM summary) where round_id='#{round_id}'"
  end

  def query_insert_seat_result(result)
    cols = ["player_id", "seat_position"]
    vals = [result.player_id, result.position]
    query_smart_insert("seat_result", cols, vals)
  end

  def query_insert_collect_result(result)
    seat_result_id = "(SELECT MAX(id) FROM seat_result)"
    amount = result.detail["amount"]

    cols = ["seat_result_id", "amount"]
    vals = [seat_result_id, amount]
    query_naive_insert("collected_result", cols, vals)
  end

  def query_insert_folded_result(result)
    street_map = { "POCKET CARDS" => 1, "FLOP" => 2, "TURN" => 3, "RIVER" => 4, "SHOWDOWN" => 5 }
    seat_result_id = "(SELECT MAX(id) FROM seat_result)"
    street_type = street_map[result.detail["street"]]
    cols = ["seat_result_id", "street_type"]
    vals = [seat_result_id, street_type]
    query_naive_insert("folded_result", cols, vals)
  end

  def query_insert_won_result(result)
    seat_result_id = "(SELECT MAX(id) FROM seat_result)"
    amount = result.detail["amount"]
    detail = "'#{result.detail["detail"]}'"
    cols = ["seat_result_id", "amount", "detail"]
    vals = [seat_result_id, amount, detail]
    query_naive_insert("win_result", cols, vals)
  end

  def query_insert_muck_result(result)
    seat_result_id = "(SELECT MAX(id) FROM seat_result)"
    cols = ["seat_result_id"]
    vals = [seat_result_id]
    query_naive_insert("muck_result", cols, vals)
  end

  def query_insert_lost_result(result)
    seat_result_id = "(SELECT MAX(id) FROM seat_result)"
    detail = "'#{result.detail["detail"]}'"
    cols = ["seat_result_id", "detail"]
    vals = [seat_result_id, detail]
    query_naive_insert("lost_result", cols, vals)
  end

  def clear_data
    @client.query("DELETE FROM seat_result")
    @client.query("DELETE FROM board")
    @client.query("DELETE FROM summary")
    @client.query("DELETE FROM action")
    @client.query("DELETE FROM street")
    @client.query("DELETE FROM player_info")
    @client.query("DELETE FROM round")
  end

  def db_check
    query = "SELECT * FROM action_name"
    p "query [ #{query} ] start..."
    client.query("SELECT * FROM action_name").each do |row|
      p row
    end
    p "query [ #{query} ] finished."
  end

  private

    def insert(query)
      begin
        @client.query(query)
      rescue Exception => e
        binding.pry
        puts "[ERROR] on query [ #{query} ] with message [ #{e} ]"
      end
    end

    def query_smart_insert(table, cols, vals)
      vals = vals.map { |v| v.is_a?(String) ? "'#{v}'" : v }
      query_naive_insert(table, cols, vals)
    end

    def query_naive_insert(table, cols, vals)
      "INSERT INTO #{table} (#{cols.join(", ")}) VALUES (#{vals.join(", ")})"
    end

    def fetch_player_role(round, player_id)
      target = round.summary.seat_results.select { |res| res.player_id == player_id }.first
      return nil unless target

      role = round.summary.seat_results.select { |res| res.player_id == player_id }.first.role
      case role
      when 1
        "sb"
      when 2
        "bb"
      else
        dealer = round.table.dealer_position == round.table.players.select { |p| p.player_id == player_id }.first.seat_position
        dealer ? "dealer" : nil
      end
    end
end

