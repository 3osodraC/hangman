# Hangman game class
class Game
  dictionary = File.foreach('google-10000-english-no-swears.txt').map(&:split)
  WORD_LIST = dictionary.flatten.select { |word| word.size >= 5 && word.size <= 12 }.freeze
end
