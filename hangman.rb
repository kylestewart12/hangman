require "json"

module Serialize
  @@serializer = JSON

  def serialize
    obj={}
    instance_variables.each do |var|
      obj[var] = instance_variable_get(var)
    end

    @@serializer.dump obj
  end

  def unserialize(string)
    obj = @@serializer.parse(string)
    obj.keys.each do |key|
      instance_variable_set(key, obj[key])
    end
  end
end

class Hangman
  include Serialize

  attr_reader :current_progress, :guesses_remaining

  def initialize
    puts "Welcome to hangman!"
    puts "Would you like to start a new game or load a saved one?"
    puts "1. New Game"
    puts "2. Load Game"

    new_or_load
    game_loop
  end

  def secret_word
    @secret_word.join
  end

  def current_progress
    @current_progress.join(" ")
  end

  def load_dictionary(dictionary_file)
    dict_file_obj = open(dictionary_file, "r")
    dictionary = []
    until dict_file_obj.eof?
      word = dict_file_obj.readline.chomp
      if word.length >=5 and word.length <=12 and word == word.downcase
        dictionary << word
      end
    end
    dictionary
  end

  def random_word
    @dictionary.sample
  end

  def make_guess
    begin
      puts "Guess a letter: "
      letter = gets.chomp.downcase
      if not /[a-z]/.match?(letter)
        raise TypeError
      end

      if @guess_history.include?(letter)
        raise StandardError
      end
    rescue TypeError
      puts "Not a valid letter. Try again."
      retry
    rescue StandardError
      puts "You've already guessed that letter!"
      retry
    end
    @guess_history << letter
    letter
  end

  def evaluate_guess(guess)
    count=0
    @secret_word.each_with_index do |letter, i|
      if letter == guess
        @current_progress[i] = letter
        count += 1
      end
    end
    if count ==1
      puts "Correct! There is 1 #{guess} in the word!"
    elsif count>1
      puts "Correct! There are #{count} #{guess}\'s in the word!"
    else
      @guesses_remaining -= 1
      puts "Sorry, there is no #{guess} in the word!"
      puts "You have #{@guesses_remaining} guess left."
    end
  end
  
  def game_loop
    until @guesses_remaining<=0
      guess = make_guess
      evaluate_guess(guess)
      puts "\n\t" + current_progress
      puts
      if @current_progress==@secret_word
        puts "You win!"
        return
      end
      puts "Enter 1 to save and quit. Press any other key to continue."
      begin
        choice = gets.chomp.to_i
      rescue
        puts "Invalid character entered"
        retry
      end
      if choice==1 and @guesses_remaining>0
        save_game
        puts "See you later!"
        return
      end
    end
    puts "You lose!"
  end

  def save_game
    file_name = "savefile"
    save_data = serialize
    File.open(file_name, "w"){|file| file.puts save_data}
  end

  def load_game
    file_name = "savefile"
    save_data = File.read(file_name)
    self.unserialize(save_data)
  end
  
  def new_or_load
    begin
      choice = gets.chomp.to_i
      if choice != 1 and choice != 2
        raise
      end
    rescue
      puts "Enter 1 or 2"
      retry
    end

    if choice==1
      @dictionary = load_dictionary("5desk.txt")
      @secret_word = random_word.split("")
      @guesses_remaining = 6
      @current_progress = ["*"]*@secret_word.length
      @guess_history = []
    else
      load_game
    end
  end
end

game = Hangman.new
