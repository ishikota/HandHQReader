class FileReader

  def self.read(file_name)
    whole_data = []
    round_data = []
    File.open(file_name) do |file|
      file.read.split("\n").each do |line|
        line = line.chomp
        if line.match(/^Stage /)
          unless round_data.empty?
            whole_data << round_data
            round_data = []
          end
          round_data << line
        else
          round_data << line unless line.empty?
        end
      end
    end
    whole_data << round_data
  end

end

