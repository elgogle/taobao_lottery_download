#encoding: utf-8

if ARGV.length < 3
	$stderr.puts "Usage: compute group_file, start row, end row"
	exit(-1)
end

group_file = ARGV.shift

unless File.file?(group_file)
	$stderr.puts "输入的文件不存在"
	exit(-1)
end

start_r = ARGV.shift.to_i
end_r = ARGV.shift.to_i
h3 = {}
h6 = {}

def resc_comb(a, n, m, tmp, cm, result)
    n.downto(m) do |i|
        tmp[m-1] = i - 1
            
        if m > 1
            resc_comb(a, i-1, m-1, tmp, cm, result)
        else
            str = ""
            (cm-1).downto(0) do |j|
                str += a[tmp[j]].to_s + " "
            end
			
            result << str.split.sort{|a,b| a.to_i <=> b.to_i}.join(" ")
        end
    end
end

def comb(a, m)
    n = a.length
    cm = m
    tmp = []
    result = []
        
    resc_comb(a, n, m, tmp, cm, result)
    return result
end

open(group_file, 'r') do |f|
	f.each_line do |l|
		next if f.lineno < start_r || f.lineno > end_r
		h3[l.strip] = 1
	end
end

open('6.txt', 'r').each do |l|
	a = comb(l.split, 3)
	b_include = true
	
	a.each do |i|
		if h3.has_key?(i)
			next
		else
			b_include = false
		end	
	end
	
	if b_include
		if h6.has_key?(l)
			h6[l] += 1
		else
			h6[l] = 1
		end
	end
end

h6.each do |k,v|
	puts "#{k.strip} : #{v}"
end

# open('r.txt', 'w') do |f|
	# h6.each do |k,v|
		# f.puts "#{k.strip} : #{v}"
	# end
# end