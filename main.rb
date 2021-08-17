dictionary = 'dictionary.txt'
random_line = (0..61406).to_a.sample
File.open(dictionary) do |file|
  random_line.times { file.readline }
  puts file.readline
end
