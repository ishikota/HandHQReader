class Player
  attr :player_id, :seat_position, :stack, :status

  def initialize(src)
    @player_id = src.match(/ - (.*?) /)[1]
    @seat_position = src.match(/Seat (\d*)/)[1].to_i
    @stack = src.match(/\$([\d\.,]*)/)[1].gsub(",","").to_f
  end
end
