# frozen-string-literal: true

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_board, :game_spectator, :game_validator, :players, :active_player, :end_game
  def initialize(game_components)
    @game_board = game_components[:board]
    @game_translator = game_components[:translator]
    @game_validator = game_components[:validator]
    @game_output = game_components[:display]
    @players = %i[white black]
    @active_player = nil
    @end_game = nil
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
      @end_game = game_validator.end_game_conditions?(player)
      selection = make_selection
      board.plot_available_moves(selection)
      # display board
      make_move(selection)
    end
  end

  def make_selection
    loop do
      selected_square = obtain_validate_input
      processed = process_input(selected_square)
      selected_piece = select_piece(processed)
      return selected_piece[-1] if selected_piece.include? :friendly

      # display invalid selection message (empty/hostile)
    end
  end

  def make_move(piece)
    destination_square = obtain_destination_square(piece)

    # capture
    game_board.update_board(piece, destination_square)

  end
  
  def obtain_destination_square(piece)
    loop do
      destination_input = obtain_validate_input(destination: true)
      destination = process_input(destination_input)
      return destination if valid_destination?(piece, destination)

      # invalid destination
    end
  end

  def valid_destination?(piece, destination)
    return false unless piece.available_moves.include? destination

    destination_contents = select_piece(destination)
    return pawn_move?(piece, destination, destination_contents) if piece.is_a? Pawn

    %i[empty hostile].include? destination_contents
  end

  def obtain_validate_input(destination: false)
    loop do
      # print prompt for move/command
      # print prompt for destination
      input = gets.chomp.downcase
      return input if valid_input?(input)
      # print invalid notation prompt
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