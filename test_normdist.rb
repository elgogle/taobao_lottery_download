require './normdist'
require './arraymodule'
require './mLotterycompute'

start_time = Time.now
puts start_time

if ARGV.size < 1
	$stderr.puts "Usage: get_group_red lottery_file"
	exit(-1)
end

lottery_file = ARGV.shift

unless File.file?(lottery_file)
	$stderr.puts "输入的文件不存在"
	exit(-1)
end

def recompute(a6, not_all, times)
	times += 1
	puts "recompute run #{times} times"
	
	t1 = Time.now
	puts "Combine 3r..."
	h_3r = {}
	a6.each do |sa6|
		sa6.combination(3).each do |sa3|
			str = sa3.join(" ")
			# h_3r[str] += 1
			if h_3r.has_key?(str)
				h_3r[str] += 1
			else
				h_3r[str] = 1
			end
		end
	end
	puts "Combine 3r #{Time.now - t1}s"
	puts
	
	t1 = Time.now
	puts "Get 3r line no..."
	i=0
	a = []
	h_3r_with_lineno_normdist = {}
	h_3r.sort_by{|k,v| v}.each do |k,v|
		i += 1
		h_3r_with_lineno_normdist[k] = [v, i, 0]
		a << v
	end
	puts "Get 3r line no #{Time.now - t1}s"
	puts
	
	t1 = Time.now
	puts "compute mean, stdev..."
	mean = a.average
	std = a.standard_deviation
	puts "compute mean, stdev #{Time.now - t1}s"
	puts
	
	puts "mean:#{mean}"
	puts "std:#{std}"
	puts
	
	t1 = Time.now
	puts "compute normdist ..."
	h_3r_with_lineno_normdist.each do |k, v|
		r_qty = v[0]
		r_lineno = v[1]
		normdist = Normdist.normdist(r_qty, mean, std, true)
		
		h_3r_with_lineno_normdist[k] = [r_qty, r_lineno, normdist]
	end
	
	puts "compute normdist #{Time.now - t1}s"
	puts
		
	h3_left = {}
	h3_right = {}
	h3_all = {}
	# f1 = open(times.to_s+'_h3_left.txt','w')
	# f2 = open(times.to_s+'_h3_right.txt','w')
	# f3 = open(times.to_s+'_h3_all.txt', 'w')
	h_3r_with_lineno_normdist.each do |k,v|
		if v[2] <= 0.62
			h3_left[k] = 1
			# f1.puts k
		end
		if v[2] >= 0.4
			h3_right[k] = 1
			# f2.puts k
		end	
		if v[2] >= 0.000911111 and v[2] <= 0.999111111
			h3_all[k] = 1
			# f3.puts k
		end
	end	

	# f1.close
	# f2.close
	# f3.close

	puts "h3_left size:#{h3_left.size}"
	puts "h3_right size:#{h3_right.size}"
	puts "h3_all size:#{h3_all.size}"
	puts
	
	t1 = Time.now
	puts "a6_left, a6_right, a6_all compute ..."
	
	a6 = (1..33).to_a.combination(6).to_a if times == 1
	a6_left, a6_right, a6_all = LotteryCompute.compute(h3_left, h3_right, h3_all, a6)
	
	not_all += a6_left+a6_right	
	out_result = a6_all-not_all
	
	puts "a6_left size: #{a6_left.size}"
	puts "a6_right size: #{a6_right.size}"
	puts "a6_all size: #{a6_all.size}"
	puts "not_all size: #{not_all.size}"
	puts "out_result size: #{out_result.size}"
	puts "a6_left, a6_right, a6_all compute #{Time.now - t1}s"
	puts
	
	
	if out_result  == a6_all
		open(times.to_s+'_test.txt', 'w') do |f|
			out_result.each do |r|
				f.puts r.join(" ")
			end
		end	
		return
	else
		open(times.to_s+'_test.txt', 'w') do |f|
			out_result.each do |r|
				f.puts r.join(" ")
			end
		end	
		recompute(out_result, not_all, times)
	end	
end

a6 = []
t1 = Time.now
puts "Read lottery file..."
open(lottery_file,"r").each do |line|
	if line.match(%r{^(\d{1,2}\s+){5}\d+})
		line_red = line.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split
		if line_red.size == 6
			a6 << line_red.map{|i| i.to_i}.sort
		end
	end
end
puts "Read lottery file #{Time.now - t1}s"
puts

times = 0
not_all = []
recompute(a6, not_all, times)

end_time = Time.now
puts "run seconds: #{end_time-start_time}"

