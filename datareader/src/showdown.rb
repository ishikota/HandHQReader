class Showdown
  attr :results

  def initialize(lines)
    @results = []
    _head = lines.shift
    @results = lines.inject([]) { |acc, src| acc << Result.new(src) }
  end

  class Result
    attr :player_id, :result_type, :result

    DOES_NOT_SHOW = 0
    COLLECT_CHIP = 1
    MUCK = 2
    SHOWS = 3

    def initialize(src)
      @player_id = src.match(/^(.*?) /)[1]
      read_result(src)
    end

    def read_result(src)
      if md = src.match(/ - Does not show$/)
        @result_type = DOES_NOT_SHOW
        @result = nil
      elsif md = src.match(/ Collects \$([\d\.]+)/)
        @result_type = COLLECT_CHIP
        @result = md[1].to_f
      elsif md = src.match(/ Mucks$/)
        @result_type = MUCK
        @result = nil
      elsif md = src.match(/ - Shows \[(.*)\] \((.*), (.*)\)/)
        @result_type = SHOWS
        @result = { "hole" => md[1].split, "hand" => md[2], "strength" => md[3] }
      else
        raise "received unexpected result #{src}"
      end
    end

  end
end

