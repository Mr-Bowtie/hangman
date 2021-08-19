require "pry"

DICTIONARY_FILE = "dictionary.txt"

# Contains all game logic and methods for game functions
class Game
  attr_accessor :word

  def initialize
    @word = ""
  end

  def get_word
    until long_word?
      random_line = (0..61_406).to_a.sample
      File.open(DICTIONARY_FILE) do |file|
        random_line.times { file.readline }
        self.word = file.readline
      end
    end
  end

  def long_word?
    (5..12).include?(word.length)
  end
end

hangman = Game.new
hangman.get_word
puts hangman.word
