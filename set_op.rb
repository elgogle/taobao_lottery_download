#encoding: utf-8
# require 'pp'
if ARGV.size < 1
	$stderr.puts "Usage: set_op set_file1+/-set_file2+/-..."
	exit(-1)
end

op_s = ARGV.join("")

set_1f = op_s.match(%r{[\w|\d|\_|\.]*})[0]

t = op_s.scan(%r{([+|-][\w|\d|\_|\.]*)})

class SourceSet
	attr_reader :set
	
	def initialize(source_file)
		@set = []
		if File.file?(source_file)
			open(source_file, 'r').each do |line|
				# puts line
				@set << line.split(':')[0].split.sort{|a,b| a.to_i <=> b.to_i}.join(" ")
			end
		end	
	end
	
	def opf(o_file, op)
		if File.file?(o_file) and (op == '+' or op == '-')
			a = []
			open(o_file, 'r').each do |line|
				a << line.split(':')[0].split.sort{|a,b| a.to_i <=> b.to_i}.join(" ")
			end
			
			case op
			when '+'
				@set |= a
			when '-'
				@set -= a
			end
		end
	end
end

s1 = SourceSet.new(set_1f)
t.each do |t|
	a = t[0]
	op = a[0]
	f = a[1..a.size-1]

	s1.opf(f, op)
end

s1.set.each do |s|
	puts s
end
