#encoding: utf-8
# require 'mysql'
require "iconv"

lottery_file = ARGV.shift
issue = lottery_file.match(%r{(\d+)})[1].to_s

def parse_order(order)
    real_order = nil
	danma=nil
	red_ball=nil
	blue_ball=nil
	total_pailie=[]
	
	real_order = order.match(%r{^[\(|\d][\)|\d\s]*:\d[\d|\s]*})
	# puts real_order
	return if real_order==nil	
	
	if real_order.to_s.match(%r{\([|\d|\s]+\)})
		danma = real_order.to_s.match(%r{\(([\d|\s]+)\)})[1].to_s.split
		red_ball = real_order.to_s.match(%r{\)([\d|\s]+)})[1].to_s.split
	else
		red_ball = real_order.to_s.match(%r{([\d|\s]+)})[1].to_s.split
	end
	
	if real_order.to_s.match(%r{:([\d\s]+)})
		blue_ball = real_order.to_s.match(%r{:([\d\s]+)})[1].split
	end
	
	return if blue_ball==nil
	
	pailie = []
	tmp = []
	pailie_len=nil

	if danma
		pailie_len = 6-danma.length
		combine(red_ball, red_ball.length, pailie_len, tmp, pailie_len,pailie)		
	elsif red_ball.length > 6
		pailie_len = 6
		combine(red_ball, red_ball.length, 6, tmp, pailie_len, pailie)
	else
		pailie << red_ball.join(" ").strip
	end
	
	blue_ball.each do |blue|
		return if blue.to_i > 16
		pailie.each do |red|
			if danma
				total_pailie << danma.join(" ").strip + " " +red + " " + blue.to_s
			else
				total_pailie << red + " " + blue.to_s
			end
		end
	end

	return total_pailie
end

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

# a=%w(01 05 10 12 15 20 21 23)
# mm=2
# b=[]
# combine(a,a.length,2,b,mm)

if lottery_file
	puts issue
	# dbh = Mysql.real_connect('localhost', 'root', '', 'Lottery')
	
	open(issue+".txt", "w") do |f|
		open(lottery_file,"r").each do |line|
			p=parse_order(Iconv.iconv("GB2312//IGNORE","UTF-8//IGNORE",line).join())
			
			if p!=nil && p.length > 0
				p.each do |str|
					
					ball = str.split
					if ball.size == 7
						red = ball[0,6].sort				
						blue = ball[6]
						
						f.puts "#{red[0]} #{red[1]} #{red[2]} #{red[3]} #{red[4]} #{red[5]}:#{blue}"
						# dbh.query("insert into ssq_master values(#{issue},#{red[0]},#{red[1]},#{red[2]},#{red[3]},#{red[4]},#{red[5]},#{blue})")					
					end
				end	
			end
		end
	end
	
	# dbh.close
end