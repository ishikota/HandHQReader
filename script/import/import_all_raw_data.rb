require 'find'

# This script import all handhq source which is under raw_data directory.
# Becareful not to include space character in handhq source file like below
# raw_data/10/abs NLH handhq_5-OBFUSCATED.txt.
# Run below command in source directory will replace space character with under score
# for f in *\ *; do mv "$f" "${f// /_}"; done

src_dir_path = File.join(File.expand_path(File.dirname($0)), "..", "..", "raw_data")
script_path = File.join(File.expand_path(File.dirname($0)), "_import_data_to_mysql.rb")
Find.find(src_dir_path) { |file|
  next unless FileTest.file?(file) && file.match(/.*handhq.*txt$/)
  puts "Start importing file [#{file}] ..."
  puts `ruby #{script_path} #{file}`
  puts "Finished importing file [#{file}]\n"
}
