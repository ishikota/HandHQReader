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
    query_insert("round", cols, vals)
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
    query_insert("player_info", cols, vals)
  end

  def clear_data
    @client.query("DELETE FROM collected_result")
    @client.query("DELETE FROM win_hole_relation")
    @client.query("DELETE FROM win_result")
    @client.query("DELETE FROM muck_hole_relation")
    @client.query("DELETE FROM muck_result")
    @client.query("DELETE FROM lost_hole_relation")
    @client.query("DELETE FROM lost_result")
    @client.query("DELETE FROM summary_result_relation")
    @client.query("DELETE FROM seat_result")
    @client.query("DELETE FROM board_card_relation")
    @client.query("DELETE FROM board")
    @client.query("DELETE FROM summary")
    @client.query("DELETE FROM street_action_relation")
    @client.query("DELETE FROM action")
    @client.query("DELETE FROM round_street_relation")
    @client.query("DELETE FROM street")
    @client.query("DELETE FROM player_info")
    @client.query("DELETE FROM round_playerinfo_relation")
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

    def query_insert(table, cols, vals)
      vals = vals.map { |v| v.is_a?(String) ? "'#{v}'" : v }
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

