require 'bundler/setup'

Bundler.require
def generate(key, size)
	RubyIdenticon.create_and_save(key, "data/#{key}-#{size}.jpeg", square_size: size, border_size: 5)
end

Dir.mkdir("data") unless File.exists?("data")
charSet = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9","a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

i = 0
charSet.permutation(3).each do |perm|
	key = perm.join
	[5, 25, 45].each do |size|
		generate(key, size)
	end
	i+=1
	p i
end




