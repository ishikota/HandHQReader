# HOW TO USE
# ruby ~/handHQReader/script/import_data_to_mysql.rb "handhq_data_file_path"

# root path of handHQReader like "/Users/kota/development/handHQReader"
root = File.absolute_path(File.join(File.dirname(__FILE__), "..", ".."))
data_file_path = ARGV.first

require File.join(root, "dbwriter", "dbwriter.rb")
require File.join(root, "datareader", "src", "round_read_helper.rb")
Dir[File.join(root, "datareader", "src", "**/*.rb")].each{ |f| require f }

# Separate file data by each round
round_data = FileReader.read(data_file_path)

# convert round text data into ruby object
round_objs = []
p "[LOG] Start to parse data src into Round object."
round_data.each do |src|
  begin
    obj = Round.new(src)
    round_objs << obj
  rescue Exception => e
    p "[ERROR] Failed to parse round object on file [#{data_file_path}]"
  end
end
p "[LOG] Finish to parse (success rate : #{round_objs.size}/#{round_data.size})"

# Fetch round info from object and write into db
writer = DBWriter.new
write_counter = 0

round_objs.each { |round|
  begin
    writer.write_round_data(round)
    write_counter += 1
  rescue Exception => e
    p "[ERROR] Failed to write round:#{round.round_id} info."
    p "[ERROR] #{e}"
  end
}
p "[LOG] Inserted #{write_counter} round data (success rate : #{write_counter}/#{round_objs.size})"
p "[LOG] Finish script. bye..."

