require 'erb'
require 'yaml'
#Visual For Hangman Game
class Board
  attr_accessor :hangman
  def initialize(hangman)
    @hangman = hangman
  end

  def display()
    puts "remaining_guess: #{hangman.remaining_guess}"
    print diagram
    puts hangman.player_guess
    puts "Wrong_attemptsf: " + hangman.wrong_attempts.join(',')
  end

  def show_result()
    word = hangman.player_guess.split(' ')
    word = word.join('')
    if hangman.remaining_guess == 0
      puts 'Game Over!'
      puts "The word is #{hangman.word_to_guess} "
    elsif word == hangman.word_to_guess
      puts 'Congratulations! You Win!'
    end
  end

  def insert_letter(letter)
    hangman.letter_attempts.push(letter)
    hangman.remaining_guess -= 1 unless hangman.word_to_guess.include?(letter)
    hangman.include_letter(letter)
  end
  private
  def diagram()
    template = File.read("stickman.erb")
    erb = ERB.new(template)
    result = erb.result(binding)
    puts ""
    puts result
  end

  def show_instructions
    puts "Type only one letter to guess each letters one by one"
    puts "Type save in order to save your game"
    puts 'Type load to load your game that is saved"'
  end
end
#Sets the rules for the game
class Hangman 
  attr_accessor :word_to_guess, :remaining_guess, :player_guess, :letter_attempts, :save_count
  attr_reader :dictionary, :board
  def initialize
    @dictionary = "5desk.txt"
    @letter_attempts = []
    @remaining_guess = 10
    @player_guess = ''
    @word_to_guess = ''
    @board = Board.new(self)
  end

  def start
    show_instructions()
    self.word_to_guess = get_random_word
    self.player_guess = fill_with_blanks(word_to_guess.length)
    board.display()
    while game_over? == false
      play_game
      board.display()
    end
    board.show_result
  end

  def play_game
    puts "Type only one letter to guess each letters one by one"
    command = gets.chomp
    save_game if command == 'save'
    load_game if command == 'load'

    if is_a_letter?(command)
      board.insert_letter(command)
    end
  end

  def wrong_attempts
    wrong_attempts = []
    letter_attempts.each do |letter|
      wrong_attempts.push(letter) if is_included?(letter,wrong_attempts)
    end
    wrong_attempts
  end

  def is_a_letter?(letter)
   return letter.length == 1  && (letter.downcase != 'save' || letter.downcase !='load')
  end

  def game_over?
    word = player_guess.split(' ')
    word = word.join('')
    return remaining_guess == 0 || word == word_to_guess
    end


  def include_letter(letter)
    word = self.player_guess.split(' ')
    i = 0
    while i < word_to_guess.length
      if letter.downcase == word_to_guess[i].downcase
        word[i] = word_to_guess[i]
      end
      i += 1
    end
    self.player_guess = word.join(' ')
  end

  private

  def is_included?(letter, array)
    unless array.include?(letter)
      unless word_to_guess.include?(letter.downcase) || word_to_guess.include?(letter.upcase)
        return true
      end
    end
    return false
  end

  def get_random_word()
    word = ''
    File.open("5desk.txt",'r') do |file|
      lines = file.readlines
      random_index = 0
      while !is_between_5_and_12?(lines[random_index])
        random_index = Random.rand(lines.length)
        end
      word = lines[random_index]
    end
    word = word[0..word.length - 3]
  end


  def save_game()
    count = 0
    file = ''
    file = "saves/#{count}.yaml"
    while File.exists?("saves/#{count}.yaml")
      count += 1
      file = "saves/#{count}.yaml"
    end
    File.open(file,"w") do |file|
      file.puts YAML::dump(self)
    end
  end

  def show_saved_files()
    id = 0
    file_name = ''
    while !File.exists?(file_name) 
      file_name = "saves/#{id}.yaml"
      puts "Number: #{id}"
      line = File.readline(file_name)
      next if line.contains?("word_to_guess")
      puts line
      id += 1
    end
  end

  def show_save_content(filename)
    File.open(filename,"w") do |file| 

    end
  end

  def load_game()
    number = ''
    show_saved_files()
    puts "Choose your savestates" 
    number = gets.chomp.to_i

    File.open("saves/#{number}.yaml","r") do |file|
      savestate = YAML::load(file)
      self.letter_attempts = savestate.letter_attempts
      self.remaining_guess = savestate.remaining_guess
      self.word_to_guess = savestate.word_to_guess
      self.player_guess = savestate.player_guess
    end
  end

  def is_between_5_and_12?(word)
    word_length = word.length - 2
   return word_length >= 5 &&  word_length <= 12
  end

  def fill_with_blanks(word_length)
    i = 0
    word = ''
    while i < word_length
      word += ("_ ")
      i += 1
    end
    word
  end
end

class SaveFileManager
  def initialize()

  end
end

a = Hangman.new
a.start
