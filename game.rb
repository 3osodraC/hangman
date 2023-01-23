require 'colorize'

# Hangman game class
class Game
  # Filters the dictionary, keeps words with 5-12 characters.
  dictionary = File.foreach('google-10000-english-no-swears.txt').map(&:split)
  WORD_LIST = dictionary.flatten.select { |word| word.size >= 5 && word.size <= 12 }.freeze

  def initialize
    @word = ''
    @lives = 6
    @wrong_guesses = { list: [], display: '' }
    @right_guesses = { list: [], display: '' }
  end

  def greet
    puts "#{'Welcome to Hangman!'.colorize(:light_blue)}\n\nA #{'random word'.bold} has been selected. You start with #{
    @lives} lives, \nyou will have to guess each letter in the word every \ntime you make a #{
    'wrong'.bold} guess, you #{'lose a life'.colorize(:red)}.\n\n"
  end

  def guess_match?(guess)
    match = false
    @word.each_char { |char| match = true if char == guess }
    match
  end

  def guess_index(guess)
    index = []
    @word.each_char.with_index { |char, i| index << i if char == guess }
    index
  end

  def play
    greet
    select_word
    display

    while @lives.positive?
      guess = prompt_guess
      # update_data
    end
  end

  def prompt_guess
    prompt = ''
    until valid_prompt?(prompt)
      print "\nGuess: "
      prompt = gets.chomp
    end
    puts "\n"
    prompt
  end

  def select_word
    @word = WORD_LIST[rand(WORD_LIST.size)]
  end

  def update_display
    @word.size.times { @right_guesses[:display] << '_ ' } if @right_guesses[:display].empty?

    case @lives
    when 5..6
      puts "Lives: #{@lives}".colorize(:green)
    when 3..4
      puts "Lives: #{@lives}".colorize(:yellow)
    when 0..2
      puts "Lives: #{@lives}".colorize(:red)
    end

    puts @right_guesses[:display]
  end

  # def update_data

  # end

  def valid_prompt?(prompt)
    valid = nil
    valid = true if prompt.match(/[a-zA-Z]/) && prompt.size == 1
    valid
  end
end

hangman = Game.new
hangman.play
