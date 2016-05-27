class Table
  attr :name, :dealer_position, :players

  def initialize(src)
    @name = src.match(/Table: ([\s\w]*) \(/)[1]
    @dealer_position = src.match(/#(\d*)/)[1].to_i
    @players = []
  end
end
