# frozen-string-literal: true

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_output, :game_board, :game_spectator, :game_validator, :players, :active_player, :end_game

  COMMANDS = %W[quit commands save]

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
      game_output.take_snapshot(board).display_game_state
      @end_game = game_validator.end_game_conditions?(player)
      selection = make_selection
      board.plot_available_moves(selection)
      # display board
      make_move(selection)
    end
  end

  def make_selection
    loop do
      input = obtain_validate_input
      return if input == 'quit'

      handle_commands(input) if COMMANDS.include? input
      processed = process_input(input)
      selected_piece = select_piece(processed)
      return selected_piece[-1] if selected_piece.include? :friendly

      selection_messages(selected_piece[0])
    end
  end

  def selection_messages(key)
    case key
    when :hostile
      game_output.text_message(:hostile_selection)
    else
      game_output.text_message(:empty_selection)
    end
  end

  def handle_commands(command)
    command_methods = { 'commands' => :commands, 'save' => :serialise }
    send(command_methods[command])
  end

  def commands
    game_output.text_message(:command_list_msg)
    game_output.display_game_state
  end

  def serialise
    
  end

  def make_move(piece)
    board_snapshot = game_board.dup
    loop do
      destination_square = obtain_destination_square(piece)
      game_board.update_board(piece, destination_square)
      break unless king_in_check?(piece.colour)

      game_output.text_message(:check_msg, active_player)
    end


  end
  
  def obtain_destination_square(piece)
    loop do
      destination_input = obtain_validate_input(destination: true)
      destination = process_input(destination_input)
      return destination if valid_destination?(piece, destination)

      game_output.text_message(:invalid_destination)
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
      input_messages(destination)
      input = gets.chomp.downcase
      return input if valid_input?(input)

      game_output.text_message(:invalid_notation)
    end
  end

  def input_messages(destination)
    if destination
      game_output.text_message(:selection_promt, active)
    else
      game_output.text_message(:destination_prompt, active_player)
    end
  end

  def valid_input?(input)
    COMMANDS.include? input or @game_translator.focus_on(input).valid_notation?
  end

  # Interface with Board class
  def select_piece(coords)
    board.select_square(coords, active_player)
  end

  def process_input(input = nil)
    # quick_move translations
    game_translator.translate_location(input)
  end
  
end