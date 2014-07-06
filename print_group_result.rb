#encoding: utf-8

lottery = ARGV.shift
group=ARGV.shift

# puts lottery
# puts group

$order=[]

def combine(a, n, m, b, cm)
	n.downto(m) do |i|
		b[m-1] = i-1
		if m>1
			combine(a,i-1,m-1,b,cm)
		else
			s = ""
			(cm-1).downto(0) do |j|
				s += a[b[j]].to_s + " "
			end
			$order << s.strip
		end
	end
end

a=lottery.split
tmp=[]
l=a.length
m=group.to_i

combine(a,l,m,tmp,m)

$order.sort.each do |i|
	a=i.split
	puts a.sort.join(" ")
end

