#encoding: utf-8

file=ARGV.shift

red_set={}
blue_set={}
	
open(file,'r').each do |line|
	if line.match(%r{\:(\d+)})
		blue = line.match(%r{\:(\d+)})[1].to_s
		if blue_set.has_key?(blue)
			blue_set[blue] +=1
		else
			blue_set[blue] = 1
		end
	end
	
	if line.match(%r{[\d|\s]+})
		red = line.match(%r{[\d|\s]+})[0].split
		red.each do |r|
			if red_set.has_key?(r)
				red_set[r] +=1
			else
				red_set[r] = 1
			end
		end
	end
end

open('count_blue_red_'+file, 'w') do |f|
	blue_set.sort_by{|k,v| v}.reverse.each do |key,value|
		f.puts key.to_s + ' ' + value.to_s
	end

	30.times do
		f.print '-'
	end
	f.puts

	red_set.sort_by{|k,v| v}.reverse.each do |key,value|
		f.puts key.to_s + ' ' + value.to_s
	end
end