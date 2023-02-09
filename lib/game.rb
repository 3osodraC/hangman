# frozen_string_literal: true

require 'colorize'
require 'yaml'

# Hangman game class
class Game
  attr_accessor :word, :lives, :guess, :wrong_guesses, :correct_guesses

  # Filters the dictionary, keeps words with 5-12 characters.
  dictionary = File.foreach('dictionary.txt').map(&:split)
  WORD_LIST = dictionary.flatten.select { |word| word.size >= 5 && word.size <= 12 }.freeze

  def initialize
    @word = ''
    @lives = 6
    @guess = ''
    @wrong_guesses = []
    @correct_guesses = { list: [], display: [] }
  end

  # Selects a saved game.
  def choose_save(saved_games)
    valid_save = false
    save = ''

    until valid_save
      puts 'Select your saved game: '
      save = gets.chomp

      if saved_games.include?(save)
        valid_save = true
      else
        puts 'Invalid save.'.colorize(:light_red)
      end
    end

    save
  end

  # (BROKEN) Assigns all instance variables of the saved game to the current game.
  def deserialize(choose_save)
    saved = File.open(File.join(Dir.pwd, "saves/#{choose_save}.yml"), 'r')
    data = YAML.load(saved)
    data.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  # Displays all data
  def display
    # p @word
    @word.size.times { @correct_guesses[:display] << '_ ' } if @correct_guesses[:display].empty?

    case @lives
    when 5..6
      puts "Lives: #{@lives}".colorize(:green)
    when 3..4
      puts "Lives: #{@lives}".colorize(:yellow)
    when 0..2
      puts "Lives: #{@lives}".colorize(:red)
    end

    puts "Wrong Guesses: #{@wrong_guesses.join}" unless @wrong_guesses.empty?
    puts @correct_guesses[:display].join.colorize(:light_blue)
  end

  def greet
    puts "\n#{'Welcome to Hangman!'.colorize(:light_blue)}\n\nA #{'random word'.bold} has been selected. You start with #{
    @lives} lives, \nyou will have to guess each letter in the word every \ntime you make a #{
    'wrong'.bold} guess, you #{'lose a life'.colorize(:red)}.\nType 'save' at any time to #{'save your game'.bold}."
  end

  # Returns whether guess is correct or not.
  def guess_match?(guess)
    match = false
    @word.each_char { |char| match = true if char == guess }
    match
  end

  # Returns the indexes of the match (e.g. Guess: A | Word: Potato | Index: [3]).
  def guess_index(guess)
    index = []
    @word.each_char.with_index { |char, i| index << i if char == guess }
    index
  end

  # Loads the selected saved game by #deserialize -ing the object selected by #choose_game
  def load_game
    unless Dir.exist?('saves')
      puts "\nNo available save files.".colorize(:light_red)
      return
    end

    saved_games = saved_files
    puts saved_games
    deserialize(choose_save(saved_games))
  end

  # Calls all methods needed for game execution.
  def play
    greet
    select_word

    while @lives.positive?
      display
      @guess = prompt_guess
      update_data

      if win?
        puts "#{@correct_guesses[:display].join}\n\n"
        puts "CONGRATULATIONS! #{'YOU WON! :D'.colorize(:green)}"
        return
      end
    end

    puts "#{'You lost :('.colorize(:red)} You'll get 'em next time."
    puts "The secret word was #{@word.colorize(:light_blue)}."
  end

  # Verifies prompt using #valid_prompt? then returns the user input.
  def prompt_guess
    prompt = ''

    until valid_prompt?(prompt) || prompt.downcase == 'save'
      print "\nGuess: "
      prompt = gets.chomp
    end

    save_game if prompt.downcase == 'save'

    puts "\n"
    prompt.downcase
  end

  # Saves current game.
  def save_game
    print 'Enter save file name: '
    save = gets.chomp
    puts "\n"

    Dir.mkdir('saves') unless Dir.exist?('saves')
    File.open("saves/#{save}.yml", 'w') { |file| YAML.dump([] << self, file) }
    exit
  end

  # Shows all saved game files.
  def saved_files
    puts 'Saves: '
    Dir['saves/*'].map { |file| file.split('/')[-1].split('.')[0] }
  end

  # Picks a random word from the list.
  def select_word
    @word = WORD_LIST[rand(WORD_LIST.size)]
  end

  # Title screen for mode selection before the game starts
  def title_screen
    puts '-=-=-=-=-Hangman-=-=-=-=-'.bold
    puts "\n#{'New Game'.colorize(:light_cyan)} -> 1\n#{'Load Game'.colorize(:cyan)} -> 2\n\n"

    mode = ''
    until mode.match(/[1-2]/)
      print 'Select Mode: '
      mode = gets.chomp
    end

    load_game if mode == '2'
    play
  end

  # Updates @lives, @correct_guesses & @wrong_guesses.
  # Using #guess_index.each, it pushes the guess to its correct
  # location in the @correct_guesses hash.
  def update_data
    if guess_match?(@guess)
      guess_index(@guess).each do |item|
        @correct_guesses[:display][item] = "#{@guess} "
        @correct_guesses[:list][item] = @guess
      end
    else
      @lives -= 1
      @wrong_guesses << "#{@guess} "
    end
  end

  # Verifies if the prompt is alphabetical and only 1 character long.
  def valid_prompt?(prompt)
    valid = nil
    valid = true if prompt.match(/[a-zA-Z]/) && prompt.size == 1
    valid
  end

  def win?
    return true if @correct_guesses[:list].join == @word
  end
end

hangman = Game.new
hangman.title_screen
