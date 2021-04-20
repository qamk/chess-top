# frozen-string-literal: true

require_relative './board'
require_relative './translator'
require_relative './spectator'

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_board, :game_spectator, :players, :active_player
  def initialize(game_components)
    @game_board = game_components[:board]
    @game_translator = game_components[:translator]
    @game_spectator = game_components[:spectator]
    @players = %i[white black]
    @active_player = nil
  end

  def play
    # print welcome
    # print board
    # initialise board
    game_start

  end

  def game_start
    players.cycle do |player|
      @active_player = player
      # board in check/checkmate
      selection = make_selection
      make_move(selection)
    end
  end

  def make_selection
    loop do
      selected_square = obtain_validate_input
      processed = process_input(selected_square)
      selected_piece = select_piece(processed)
      return selected_piece[-1] if selected_piece.include? :friendly

      # display invalid selection message
    end
  end

  def make_move(piece)
    destination_square = verify_destination
    # capture
    game_board.update_board(piece, destination_square)

  end
  
  def verify_destination
    loop do
      destination_input = obtain_validate_input(destination: true)
      destination = process_input(destination_input)
      destination_contents = select_piece(destination)
      return destination unless destination_contents.include? :friendly

      # invalid destination
    end
  end

  def obtain_validate_input(destination: false)
    loop do
      # print prompt for move/command
      # print prompt for destination
      input = gets.chomp
      return input if valid_input?(input)
    end
  end

  def valid_input?(input)
    @game_translator.focus_on(input).valid_notation?
  end

  # Interface with Board class
  def select_piece(coords)
    board.select_square(coords, active_player)
  end

  def process_input(input = nil)
    # perform + display
    # ...
    game_translator.translate_location(input)
  end
  
end