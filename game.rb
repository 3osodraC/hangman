require 'colorize'

# Hangman game class
class Game
  dictionary = File.foreach('google-10000-english-no-swears.txt').map(&:split)
  WORD_LIST = dictionary.flatten.select { |word| word.size >= 5 && word.size <= 12 }.freeze

  def initialize
    @word = ''
    @lives = 6
    @wrong_guesses = 'Wrong guesses: '
    @correct_guesses = ''
  end

  def greet
    puts "#{'Welcome to Hangman!'.colorize(:light_blue)}\n\nA #{'random word'.bold} has been selected, you have #{
    @lives} lives, \nevery time you make a #{'wrong'.bold} guess, you #{'lose a life'.colorize(:red)}."
  end

  def play
    greet
    select_word
    update_display
  end

  def select_word
    @word = WORD_LIST[rand(WORD_LIST.size)]
  end

  def update_display
    @word.size.times { @correct_guesses << '_ ' } if @correct_guesses.empty?
    puts @correct_guesses
  end
end

hangman = Game.new
hangman.play
