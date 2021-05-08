# frozen-string-literal: true

# rubocop: disable Metrics/ClassLength

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_output, :game_board, :game_spectator,
              :game_validator, :players, :active_player, :end_game

  COMMANDS = %w[quit commands save].freeze

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
    game_board.create_starting_board
    game_output.display_game_state
    game_start until end_game?
    game_over_message
  end

  def game_start
    players.cycle(2) do |player|
      @active_player = player
      selection = selection_processes
      if selection == :quit
        @end_game = true
        break
      end

      movement_processes(selection)
      promotion_check(selection)
    end
  end

  def obtain_validate_input(destination: false)
    loop do
      input_messages(destination)
      input = gets.chomp.downcase
      return input if valid_input?(input)

      game_output.text_message(:invalid_notation)
    end
  end
  
  def selection_processes
    game_output.take_snapshot(board).display_game_state
    game_validator.take_board_snapshot(game_board)
    make_selection
  end

  def make_selection
    loop do
      input = obtain_validate_input
      return :quit if input == 'quit'

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
  
  def movement_processes(selection)
    game_validator.plot_available_moves(selection)
    game_output.obtain_last_piece(selection).display_game_state

    make_move(selection)
    @game_board = game_board.board
  end

  def make_move(piece)
    loop do
      can_move = validate_move(piece)
      break if can_move == true

      movement_messages(can_move)
      # print a message based on the tag
    end
    # update board
  end

  def movement_messages(tag)
    movement_issues = {
      check: [:check_msg, active_player],
      ally: [:ally_occupied],
      no_castle: [:invalid_castle],
      no_en_passant: [:invalid_en_passant],
      not_in_moveset: [:invalid_destination]
    }
  end

  def validate_move(piece)
    board_snapshot = game_board.dup
    destination = obtain_destination_square(piece)
    return :check if game_validator.king_in_check?(piece.colour)

    meta_info = obtain_meta_info
    valid_move = move_is_valid?(piece, destination, meta_info)
    # game_board.update_board(piece, destination_square)

    # game_output.text_message(:check_msg, active_player)
    # @game_board = board_snapshot
  end

  
  def obtain_meta_info(piece, destination)
    { category: categorise_move(piece, destination), contents: select_piece(destination) }
  end

  def categorise_move(piece, destination)
    return :castling if castling_on_starting_rank?(piece, destination)

    #return :en_passant if game_validator.en_passant_check?(p, d)

    :normal
  end

  def obtain_destination_square(piece)
    destination_input = obtain_validate_input(destination: true)
    process_input(destination_input)
  end

  def move_is_valid?(piece, destination, meta_info)
    return :ally if meta_info[:contents] == :friendly

    category = meta_info[:category]
    method = category == :normal ? :validate_normal_move? : :validate_special_move
    send(method, piece, destination, meta_info)
  end

  def validate_special_move(piece, destination, meta_info)
    tag = meta_info[:category]
    case tag
    when :castling
      game_validator.castling(piece, destination)
    when :en_passant
      # piece, destination
    end
  end
  
  def castling_on_starting_rank?(piece, destination)
    return false unless piece.is_a? King

    # =====================
    rank = piece.colour == :white ? 7 : 0
    (piece.location[0] == rank) && (destination[0] == rank)
  end

  def validate_normal_move?(piece, destination, meta_info)
    return :not_in_moveset unless piece.available_moves.include? destination

    contents = meta_info[:contents]
    return game_validator.pawn_move?(piece, destination, contents) if piece.is_a? Pawn


    %i[empty hostile].include? contents
  end
  
  def promotion_check(selection)
    return unless selection.is_a? Pawn

    board_end = active_player == :white ? 0 : 7
    promote = selection.location[0] == board_end
    return unless promote

    new_piece = new_piece_input.to_sym
    game_board.promote(selection, new_piece)
    game_output.text_message(:promotion_success, new_piece)
  end

  def new_piece_input
    game_output.text_message(:promotion_prompt)
    loop do
      valid_promotions = %w[queen q rook r bishiop b knight n]
      response = gets.chomp.downcase[0]
      return response if valid_promotions.include? response

      game_output.text_message(:invalid_promotion)
    end
  end

  def end_game?
    return true if @end_game

    @end_game = players.select { |player| game_validator.end_game_conditions?(player) }
    !end_game.empty?
  end

  def game_over_message
    case end_game.length
    when 0
      game_output.text_message(:quit_msg, nil, false)
    when 1
      game_output.text_message(:checkmate_msg, end_game[0], false)
    else
      game_output.text_message(:stalemate_msg, nil, false)
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
    # board, active_player
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