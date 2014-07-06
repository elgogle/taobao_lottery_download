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

test = (0..33).to_a
# test = [03, 10, 12, 13, 27, 30]
# puts test.to_s

a = comb(test, 6)
a.shuffle.each do |s|
	puts s
end
