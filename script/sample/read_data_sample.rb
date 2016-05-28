# root path of handHQReader like "/Users/kota/development/handHQReader"
root = File.absolute_path(File.join(File.dirname(__FILE__), ".."))
data_file_path = File.join(File.dirname(__FILE__), "sample_data.txt")
require File.join(root, "datareader", "src", "round_read_helper.rb")
Dir[File.join(root, "datareader", "src", "**/*.rb")].each{ |f| require f }

# Separate file data by each round
round_data = FileReader.read(data_file_path)

# convert round text data into ruby object
round = round_data.map { |src| Round.new(src) }
puts round.first
