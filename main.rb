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
  attr_accessor :correct_guesses, :wrong_guesses, :current_guess

  def initialize(*args)
    @correct_guesses = []
    @wrong_guesses = []
    @current_guess = ''
  end

  def get_guess
    guess = ''
    loop do
      puts 'Please enter a letter'
      guess = gets.chomp.downcase
      break if valid_input?(guess)
      puts 'Invalid input'
    end
    self.current_guess = guess
  end

  def previous_guess?(input)
    correct_guesses.include?(input) || wrong_guesses.include?(input)
  end

  def valid_input?(input)
    return false if previous_guess?(input)
    return false unless input.match?(/[a-z]/)

    true
  end

  def chances_left
    10 - wrong_guesses.size
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

  def sort_guess
    if correct_guess?
      human.correct_guesses << human.current_guess
    else
      human.wrong_guesses << human.current_guess
    end
  end

  def play_game
    computer.set_word
    loop do
      puts computer.word
      play_round
      p human.correct_guesses
      p human.wrong_guesses
      puts human.chances_left
      break if human.chances_left.zero?
    end
  end

  def play_round
    human.get_guess
    sort_guess
  end
end

human = Human.new
computer = Computer.new
hangman = Game.new(human, computer)

hangman.play_game
