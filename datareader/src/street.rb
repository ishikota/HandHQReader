class Street
  attr :name, :community_card, :actions

  def initialize(lines)
    @name = nil
    @community_card = []
    @actions = []
    head = lines.shift
    set_street_info(head)
    lines.each { |line|
      @actions << Action.new(line)
    }
  end

  def set_street_info(src)
    @name = src.match(/\* (.*) \*/)[1]
    md = src.match(/\[(.*?)\]( \[.*\])*/)
    community_src = md.nil? ? [] :
      md[2].nil? ? md[1].split :
      md[1].split + md[2].split.map { |s| s.slice(/[\w\d]+/) }
    @community_card = community_src
  end

  private

    def gen_community_card(src)
      if src.nil?
        []
      else
      end
    end

end
