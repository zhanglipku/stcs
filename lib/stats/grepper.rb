# usage: ruby grepper.rb /fully/qualified/path/to/list[accts] /fully/qualified/path/to/.gz[sources] /fully/qualified/path/to/output/directory
# filter out tweets for list of users in their respective files
require 'zlib'
require 'json'
require 'time'

# filter out tweets for list of users in their respective files
# but first, might want to clean the file up:
# grep -w --ignore-case 'bot' 1k.csv | grep -vw --ignore-case 'human.*human' | awk -F"," '{print $1}' > bots.1k
# grep -w --ignore-case 'human' 1k.csv | grep -vw --ignore-case 'bot.*bot' | awk -F"," '{print $1}' > humans.1k

acct_list = []
File.open(ARGV[0], 'r') do |f|
  f.each_line do |line|
    acct_list.push("#{line.strip!}")
  end
end # auto file close
acct_list.uniq!
acct_list.sort!
#puts acct_list

pline = ""
out = ""

file_list = Dir.entries(ARGV[1])
file_list.delete(".") # remove . from the list
file_list.delete("..") # remove .. from the list
#file_list.sort!
#puts file_list

file_list.each do |file|
  #puts ".. file: #{file} .."
  begin
    infile = open("#{ARGV[1]}/#{file}")
    gzi = Zlib::GzipReader.new(infile)
    gzi.each_line do |line|
      begin
        pline = JSON.parse(line)
        # check each line against the complete acct_list, instead of traversing over the whole .gz repeatedly
        if acct_list.include? pline['user']['screen_name']
	  #puts "found .. #{pline['user']['screen_name']} .. writing to file .."
          File.open("#{ARGV[2]}/#{pline['user']['screen_name']}", 'a') do |f|
	    f.puts(pline)
	  end # auto file close
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
end
