# root path of handHQReader like "/Users/kota/development/handHQReader"
root = File.absolute_path(File.join(File.dirname(__FILE__), ".."))
data_file_path = File.join(File.dirname(__FILE__), "sample_data.txt")

require File.join(root, "dbwriter", "dbwriter.rb")
require File.join(root, "datareader", "src", "round_read_helper.rb")
Dir[File.join(root, "datareader", "src", "**/*.rb")].each{ |f| require f }

# Separate file data by each round
round_data = FileReader.read(data_file_path)

# convert round text data into ruby object
round_objs = round_data.map { |src| Round.new(src) }

# Fetch round info from object and write into db
writer = DBWriter.new
write_counter = 0

writer.clear_data
round_objs.each { |round|
  begin
    writer.write_round_data(round)
    write_counter += 1
  rescue Exception => e
    p "[ERROR] Failed to write round:#{round.round_id} info."
    p "[ERROR] #{e}"
  end
}
writer.clear_data
p "[LOG] Inserted #{write_counter} round data #{write_counter}/#{round_objs.size}"
p "[LOG] Finish script. bye..."

