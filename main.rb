# frozen_string_literal: true

require 'pry'
require 'yaml'

DICTIONARY_FILE = 'dictionary.txt'

module Display
  def prompt(input)
    puts "==: #{input}"
  end
end

class Player
  include Display

  def initialize; end
end

class Computer < Player
  attr_accessor :word

  def initialize
    @word = ''
  end

  def set_word
    until long_word?
      random_line = (0..61_406).to_a.sample
      File.open(DICTIONARY_FILE, chomp: true) do |file|
        random_line.times { file.readline }
        self.word = file.readline.strip
      end
    end
  end

  def long_word?
    (5..12).include?(word.length)
  end
end

class Human < Player
  attr_accessor :correct_guesses, :wrong_guesses, :current_guess

  def initialize(*_args)
    @correct_guesses = []
    @wrong_guesses = []
    @current_guess = ''
  end

  def get_guess
    guess = ''
    loop do
      prompt 'Please enter a letter'
      prompt "(enter 'save' or 'quit' at anytime)"
      guess = gets.chomp.downcase.strip
      break if valid_guess?(guess)

      prompt 'Invalid input'
    end
    self.current_guess = guess
  end

  def previous_guess?(input)
    correct_guesses.include?(input) || wrong_guesses.include?(input)
  end

  def valid_guess?(input)
    return true if input == 'save'
    return true if input == 'quit'
    return false if input.length > 1
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
  extend Display
  include Display
  attr_accessor :human, :computer

  def initialize(human, computer)
    @human = human
    @computer = computer
  end

  def self.start_game(human, computer)
    system('clear')
    prompt 'Welcome to Hangman!'
    prompt 'Would you like to load a save or start an new game? (enter load or new)'
    choice = ''
    loop do
      choice = gets.chomp.downcase.strip
      break if valid_start_input?(choice)

      prompt 'Invalid input: please enter load or new'
    end
    choice == 'load' ? load_game : new(human, computer)
  end

  def self.valid_start_input?(input)
    %w[load new].include?(input)
  end

  def self.show_saves
    puts '===== Save Files ====='
    Dir.each_child('saves') { |save| puts save.gsub('.yml', '') }
  end

  def self.save_game(game)
    system('clear')
    show_saves
    prompt 'Input save name (enter name of old save to overwrite)'
    save_name = gets.chomp
    File.open("saves/#{save_name}.yml", 'w') do |file|
      file.write(YAML.dump(game))
    end
    prompt 'Game saved'
    sleep 1.5
    system('clear')
  end

  def self.load_game
    system('clear')
    show_saves
    prompt 'Choose a saved game to load'
    save = ''
    loop do
      save = gets.chomp + '.yml'
      break if File.exist?("saves/#{save}")
      prompt 'File does not exist.'
    end
    game = nil
    File.open("saves/#{save}", 'r') do |file|
      game = YAML.load(file)
    end
    game
  end

  def display_word_in_progress
    wip = '_' * computer.word.length
    human.correct_guesses.each do |letter|
      indicies = []
      computer.word.chars.each_with_index do |char, idx|
        indicies << idx if char.downcase == letter
      end
      indicies.each { |idx| wip[idx] = letter }
    end
    prompt wip
  end

  def correct_guess?
    computer.word.include?(human.current_guess)
  end

  def sort_guess
    if correct_guess?
      human.correct_guesses << human.current_guess
    elsif human.current_guess == 'save'
      Game.save_game(self)
    elsif human.current_guess == 'quit'
      prompt 'Thanks for playing!'
      exit
    else
      human.wrong_guesses << human.current_guess
    end
  end

  def win?
    computer.word.chars.uniq.sort == human.correct_guesses.sort
  end

  def play_game
    computer.set_word
    loop do
      system('clear')
      display_round_header
      play_round
      break if human.chances_left.zero? || win?
    end
    if win?
      prompt 'You won!'
    else
      prompt "You've run out of guesses, you lose."
    end
    prompt "The word was #{computer.word}"
  end

  def display_round_header
    display_word_in_progress
    display_correct_guesses
    display_wrong_guesses
    display_chances_left
  end

  def display_correct_guesses
    print 'Correct guesses: '
    puts human.correct_guesses.join(', ')
  end

  def display_wrong_guesses
    print 'Incorrect guesses: '
    puts human.wrong_guesses.join(', ')
  end

  def display_chances_left
    prompt "Guesses remaining: #{human.chances_left}"
  end

  def play_round
    human.get_guess
    sort_guess
  end

  def welcome_screen
  end
end

human = Human.new
computer = Computer.new
hangman = Game.start_game(human, computer)

hangman.play_game
