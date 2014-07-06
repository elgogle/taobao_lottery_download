#encoding: utf-8

if ARGV.size < 2
	$stderr.puts "Usage: get_group_red lottery_file, group_num"
	exit(-1)
end

lottery_file = ARGV.shift
select_num = ARGV.shift.to_i

unless File.file?(lottery_file)
	$stderr.puts "输入的文件不存在"
	exit(-1)
end

unless select_num.to_i > 1 and select_num.to_i < 6
	$stderr.puts "分组数值不正确，必须大于1小于6"
	exit(-1)
end

$result_hash = {}

def combine(a, n, m, b, cm, out_pailie)
	n.downto(m) do |i|
		b[m-1] = i-1
		if m>1
			combine(a,i-1,m-1,b,cm,out_pailie)
		else
			s = ""
			(cm-1).downto(0) do |j|
				s += a[b[j]].to_s + " "
			end
			out_pailie << s.strip
		end
	end
end

red_ball = (1..33).to_a
select_ary = []
tmp = []
num = select_num
combine(red_ball, 33, select_num, tmp, num, select_ary)


select_hash = {}

select_ary.each do |i|
	select_hash[i.split.sort{|a,b| a.to_i <=> b.to_i}.join(" ")] = 1
end


line_count = 0
open(lottery_file,"r").each do |line|
	if line.match(%r{^(\d{1,2}\s+){5}\d+})
		line_red = line.match(%r{^(\d{1,2}\s+){5}\d+})[0].to_s.split
		if line_red
			line_count += 1
			line_select_ary = []
			tmp = []
			num = select_num
			combine(line_red, 6, select_num, tmp, num, line_select_ary)
			
			line_select_ary.each do |lsa|
				
				a = []
				# puts "lsa#{lsa}"
				lsa.split.sort{|a,b| a.to_i <=> b.to_i}.each do |i|
					a << i.to_i
				end
				str = a.join(" ")
				
				# puts str
				select_hash[str] += 1 if select_hash.has_key?(str)
				# pp select_hash[str]
			end
			
		end
	end
end

i = 1
select_hash.sort_by{|k,v| v}.each do |k,v|
	puts "#{k}:#{v}"
	# puts "#{i}:#{k}:#{v}"
	# i += 1
end
