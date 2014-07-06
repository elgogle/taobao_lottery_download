
module LotteryCompute
	def self.compute( h3_left, h3_right, h3_all, a6 )
		left = []
		right = []
		all = []
		
		a6.each do |i|
			b1 = true
			b2 = true
			b3 = true
			
			i.combination(3).each do |j|
				s = j.join(" ")
				unless h3_left.has_key?(s)
					b1 = false
				end
				unless h3_right.has_key?(s)
					b2 = false
				end
				unless h3_all.has_key?(s)
					b3 = false
				end
			end
			
		 	left << i  if b1
			right << i if b2
			all << i if b3
		end
		
		return [left, right, all]
	end	
end