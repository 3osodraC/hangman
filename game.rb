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
    @lives} lives, \nevery time you make a #{'wrong'.bold} guess, you #{'lose a life'.colorize(:red)}.\n\n"
  end

  def play
    greet
    select_word
    display

    while @lives.positive?
      guess = prompt_guess
      # right_guess?(guess)
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

  # def right_guess?(guess)

  # end

  def select_word
    @word = WORD_LIST[rand(WORD_LIST.size)]
  end

  def display
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

  def valid_prompt?(prompt)
    valid = nil
    valid = true if prompt.match(/[a-zA-Z]/)
    valid
  end
end

hangman = Game.new
hangman.play
