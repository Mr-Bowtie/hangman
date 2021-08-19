require 'pry'

DICTIONARY_FILE = 'dictionary.txt'.freeze

class Player
  def initialize; end
end

class Computer < Player
  attr_accessor :word

  def initialize()
    @word = ''
  end

  def set_word
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

class Human < Player
  attr_accessor :guesses, :chances_left, :current_guess

  def initialize(*args)
    @guesses = []
    @chances_left = 10
    @current_guess = ''
  end

  def get_guess
    puts 'Please enter a letter'
    self.current_guess = gets.chomp
    guesses << current_guess
  end

  def bad_guess
    self.chances_left -= 1
  end
end

# Contains all game logic and methods for game functions
class Game
  attr_accessor :human, :computer

  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def correct_guess?
    computer.word.include?(human.current_guess)
  end

  def play_game
    computer.set_word
    loop do
      puts computer.word
      play_round
      p human.guesses
      puts human.chances_left
      break if human.chances_left == 0
    end
  end

  def play_round
    human.get_guess
    human.bad_guess unless correct_guess?
  end
end

human = Human.new
computer = Computer.new
hangman = Game.new(human, computer)

hangman.play_game
