# frozen-string-literal: true

require_relative 'game'
require_relative 'spectator'
require_relative 'translator'
require_relative 'board'
require_relative 'rules/move_validation'
require_relative 'rules/movement'
require_relative 'display/game_output'
require_relative 'display/welcome'
require 'json'



# "Main menu" for the program
class Main
  include Welcome

  attr_reader :game_components, :game

  def initialize
    mover = Movement.new
    spectator = Spectator.new(mover)
    translator = Translator.new
    board = Board.new
    output = GameOutput.new(board)
    validator = MoveValidator.new(board, spectator, mover)

    @game_components = {
      translator: translator, board: board,
      output: output, validator: validator
     }
  end

  def greetings
    welcome_msg
    start
  end

  def start
    mode = game_mode
    send(mode) unless mode == :quit
  end

  def game_mode
    game_menu_msg
    valid_reponse = {
      '1' => :new_game, '2' => :load_game,
      'q' => :quit, 'quit' => :quit
    }
    loop do
      response = gets.chomp.downcase
      return valid_reponse[response] if valid_reponse.include? response

      game_menu_error_msg
    end
  end

  def new_game
    game = Game.new(game_components)
    puts "Starting \e[33mnew game\e[0m. Press enter to continue."
    gets
    game.start
    puts '*happy quitting sounds*'
  end

  def load_game
    save = find_old_save
    return if save.nil?

    return start if save == 'menu'

    game = Game.new(game_components)
    game.load(save)
    gets
    game.play
  end

  def find_old_save
    list_saves
    loop do
      puts 'Please enter a valid filename (without extention) or \'q\' or \'quit\' to quit \'m\' or \'menu\' to view the menu'
      response = gets.chomp.downcase
      if %w[q quit].include? response
        return
      elsif %[menu m].include? response
        return 'menu'
      end
 
      next unless File.exist?("saves/#{response}.json")

      save = File.open("saves/#{response}.json", 'r') { |file| JSON.parse file.gets }
      return save
    end
  end

  def list_saves
    files = Dir["saves/*.json"].map { |path| path.split('/')[-1] }
    return puts "There are no files available for loading" if files.empty?
    puts "The current \e[33msaves\e[0m are as follows:"
    puts files
  end

end
main = Main.new
main.greetings
