require 'colorize'

# Hangman game class
class Game
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

  def greet
    puts "#{'Welcome to Hangman!'.colorize(:light_blue)}\n\nA #{'random word'.bold} has been selected. You start with #{
    @lives} lives, \nyou will have to guess each letter in the word every \ntime you make a #{
    'wrong'.bold} guess, you #{'lose a life'.colorize(:red)}.\n\n"
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
    until valid_prompt?(prompt)
      print "\nGuess: "
      prompt = gets.chomp
    end
    puts "\n"
    prompt.downcase!
  end

  # Picks a random word from the list.
  def select_word
    @word = WORD_LIST[rand(WORD_LIST.size)]
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
hangman.play
