#encoding: utf-8

if ARGV.size < 1
	$stderr.puts "Usage: distinct_red lottery_file"
	exit(-1)
end

lottery_file = ARGV.shift

unless File.file?(lottery_file)
	$stderr.puts "输入的文件不存在"
	exit(-1)
end

result_hash = {}

open(lottery_file,"r").each do |line|
	if line.match(%r{^(\d{1,2}\s+){5}\d+})
		line_red = line.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split.sort{|a,b| a.to_i<=>b.to_i}.join(" ")
		if line_red
			result_hash[line_red] = 1 if not result_hash.has_key?(line_red)
		end
	end
end

open('distinct_' + lottery_file, 'w') do |f|
	result_hash.each_key do |k|
		f.puts k
	end
end