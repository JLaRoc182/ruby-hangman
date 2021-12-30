require 'yaml'

class Hangman

attr_accessor   :word, :word_array, :guess_progress, :guess_record, :curr_guess, :wrong_tally, :game_status, :the_hangman

  def initialize
    @file
    @words
    @word 
    @word_array = Array.new
    @guess_progress
    @guess_record = Array.new
    @curr_guess
    @wrong_tally = 0
    @game_status = "Play"  # Win, Lose, Play
    @the_hangman = [
      ['   _____', '  |    |', '  |', '  |', '  |', '  |', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |', '  |', '  |     \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |', '  |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |', '  |    |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |    |', '  |    |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |   -|', '  |    |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |', '  |   -|-', '  |    |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |    o', '  |   -|-', '  |    |', '  |   / \ ', '  |', '  |', '-----'],
      ['   _____', '  |    |', '  |    ', '  |    ', '  |    ..', '  |     >', '  |    ~', '  |  \_|_/', '  |    |', '  |   / \ ', '  |  /   \ ', '-----'],
    ]
  end

  def choose_word #chooses a random word (between 5 and 12 characters) from the 5desk.txt file, and updates game variables 
    @file = File.read("5desk.txt")
    @words = @file.split("\r\n")
    @word = ""
    until @word.length > 5 && @word.length < 12 do
      @word = @words[rand(@words.length)]
    end
    @word_array = @word.split("")
    @guess_progress = Array.new(@word.length,"_") #sets @guess progress array to the correct length
  end

  def player_guess  #asks the player to guess a letter (only accepts a single letter)
    p "Choose a letter (or save game by entering 'save'):"
    @curr_guess = gets.chomp
    if @curr_guess == 'save'
        save_game
        p 'game saved'
    else
      while @curr_guess.length > 1 do
        p "Choose a SINGLE letter:"
        @curr_guess = gets.chomp
      end
    end
  end

  def process_guess #updates game variables for the players guess
    @guess_record.push(@curr_guess)  #update your record of prior guesses with your current guess

    @word_array.each_with_index do |letter, index| # check to see if your guess matches any of the letter in the word, if it does, update your progress
      if letter == @curr_guess
        @guess_progress[index] = letter.clone
      end
    end

    if @word_array.include?(@curr_guess) #track the number of wrong guesses and status of the hangman
        p "yeah baby"
    else
        @wrong_tally += 1
    end
  end
      
  def update_game_status  #update our game status to either Win, Lose, or Play, this tells our loop what to do
    if @wrong_tally >= 7
        @game_status = "Lose"
    elsif @guess_progress.include?("_")
        @game_status = "Play"
    else
        @game_status = "Win"
    end
  end

  def update_display #display our progress based on our game status
    if @game_status == "Play"
      puts @the_hangman[@wrong_tally]
      p "Secret Word: #{@guess_progress.join("  ")}"
      p "Guess Record: * #{@guess_record.join("  ")} *"
    elsif @game_status == "Lose"
      puts @the_hangman[@wrong_tally]
      p "*** GAME OVER ***"
      p "The word was: #{@word}"
    elsif @game_status == "Win"
      puts @the_hangman[8]
      p "Secret Word: #{@guess_progress.join("  ")}"
      p "*** You WIN!!! ***"
    else
        "Game ended"
    end  
  end

  def to_yaml    # converts variables into a YAML string (used for saving games)
    YAML.dump ({
      :word => @word,
      :word_array => @word_array,
      :guess_progress => @guess_progress,
      :guess_record => @guess_record,
      :curr_guess => @curr_guess,
      :wrong_tally => @wrong_tally,
      :game_status => @game_status,
    })
  end

  def from_yaml(file)    #reads YAML strings to load variables from a saved game file
    data = YAML.load File.open(file, 'r')
    p data
    @word = data[:word]
    @word_array = data[:word_array]
    @guess_progress = data[:guess_progress]
    @guess_record = data[:guess_record]
    @curr_guess = data[:curr_guess]
    @wrong_tally = data[:wrong_tally]
    @game_status = data[:game_status]
  end

  def save_game    #method to save games using the yaml method above
    Dir.mkdir('saved') unless Dir.exist?('saved')
    p "Enter name for saved game:"
    game = gets.chomp
    filename = "saved/#{game}.txt"
    File.open(filename, 'w') do |file|
        file.puts to_yaml
    end
  end

  def load_game    #method to load saved games using the yaml method above
    p "Enter name of game you want to load"
    game = gets.chomp
    filename = "saved/#{game}.txt"
    from_yaml(filename)
  end

  def play_game    #loop to play the game, also allows you to save or load games as you play
    p "Enter 'New' or 'Load'"
    game = gets.chomp
    if game == 'Load'
        load_game
    elsif game == 'New'
        choose_word
    else
        p "you didn't enter 'New' or 'Load', you are getting a new game, have fun"
    end
        update_display
        while @game_status == "Play" do
            player_guess
            break if @curr_guess == 'save'
            process_guess
            update_game_status
            update_display
        end
  end

end

josh = Hangman.new
josh.play_game

