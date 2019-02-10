class Hangman
  attr_reader :current_progress

  def initialize(dictionary_file)
    @dictionary = load_dictionary(dictionary_file)
    @secret_word = random_word.split("")
    @guesses_remaining = 6
    @current_progress = ["*"]*@secret_word.length
    @guess_history = []
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
        break
      end
    end
  end

  def save_game

  end

end

game = Hangman.new("5desk.txt")
game.game_loop