# frozen-string-literal: true

# rubocop: disable Metrics/ClassLength

require 'json'

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_output, :game_board,
              :game_spectator, :game_validator, :players,
              :active_player, :end_game, :winner, :last_piece

  COMMANDS = %w[quit commands save].freeze

  def initialize(game_components)
    @game_board = game_components[:board]
    @game_translator = game_components[:translator]
    @game_validator = game_components[:validator]
    @game_output = game_components[:output]
    @players = %i[white black]
    @active_player = nil
    @last_piece = nil
    @end_game = false
    @winner = nil
  end

  def start
    # print welcome
    game_board.create_starting_board
    game_output.display_game_state
    play
  end

  def play
    game_start until end_game?
    game_over_message
  end

  def game_start
    players.cycle(2) do |player|
      @active_player = player
      selection = selection_processes
      movement_processes(selection) unless end_game
      promotion_check(selection) unless end_game
    end
  end

  def obtain_validate_input(destination = false)
    loop do
      input_messages(destination)
      input = gets.chomp.downcase
      return input if valid_input?(input)

      game_output.text_message(:invalid_notation)
    end
  end

  def selection_processes
    game_output.take_snapshot(game_board.board)
    game_output.display_game_state
    game_validator.take_board_snapshot(game_board.board)
    make_selection
  end

  def make_selection
    loop do
      input = obtain_validate_input
      return quit_game if input == 'quit'

      if COMMANDS.include? input
        handle_commands(input)
        next
      end

      processed = process_input(input)
      selected_piece = label_piece(processed)
      return selected_piece[-1] if selected_piece.is_a? Array

      selection_messages(selected_piece)
    end
  end

  def selection_messages(key)
    if key == :hostile
      game_output.text_message(:hostile_selection)
    else
      game_output.text_message(:empty_selection)
    end
  end

  def movement_processes(selection)
    game_validator.plot_available_moves(selection)
    game_output.obtain_last_piece(selection)
    game_output.display_game_state

    make_move(selection)
  end

  def make_move(piece, destination = '')
    loop do
      # board_snapshot = game_board.dup
      can_move, destination = validate_move(piece)
      break if (can_move == true) || end_game

      movement_messages(can_move)
      @game_board.revert_board
    end
    return if end_game

    @last_piece = piece
    game_board.update_board(piece, destination)
  end

  def movement_messages(tag)
    movement_issues = {
      check: [:check_msg, active_player],
      ally: [:ally_occupied],
      no_castle: [:invalid_castle],
      no_en_passant: [:invalid_en_passant],
      not_in_moveset: [:invalid_destination]
    }
    method_details = movement_issues[tag]
    game_output.text_message(*method_details)
  end

  def validate_move(piece)
    return :check if game_validator.king_in_check?(active_player)

    destination = obtain_destination_square
    return quit_game if destination == 'quit'

    handle_commands(destination) if COMMANDS.include? destination

    meta_info = obtain_meta_info
    valid_move = move_is_valid?(piece, destination, meta_info)

    return :check if check_after_move?(piece, destination)

    [valid_move, destination]
  end

  def check_after_move?(piece, destination)
    game_board.update_board(piece, destination)
    game_validator.take_board_snapshot(game_board.board)
    game_validator.king_in_check?(active_player)
  end

  def obtain_meta_info(piece, destination)
    { category: categorise_move(piece, destination, label_piece(destination)), contents: label_piece(destination) }
  end

  def categorise_move(piece, destination, contents)
    return :castling if castling_on_starting_rank?(piece, destination, contents)

    :normal
  end

  def obtain_destination_square
    destination_input = obtain_validate_input(true)
    process_input(destination_input)
  end

  def move_is_valid?(piece, destination, meta_info)
    return :ally if meta_info[:contents] == :friendly

    category = meta_info[:category]
    method = category == :normal ? :validate_normal_move? : :validate_castling_move
    send(method, piece, destination, meta_info)
  end

  def validate_castling_move(piece, destination, *)
    castle = game_validator.castling(piece, destination)
    return false if castle == false

    game_board.update_castle(castle)
    true
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
    en_passant = game_validator.en_passant?(piece, destination, contents) if piece.is_a? Pawn

    en_passant or %i[empty hostile].include?(contents)
  end

  def promotion_check(piece)
    return unless piece.is_a? Pawn

    board_end = active_player == :white ? 0 : 7

    return unless piece.location[0] == board_end

    new_piece = new_piece_input.to_sym
    game_board.promote(piece, new_piece)
    game_output.text_message(:promotion_success, new_piece)
  end

  def new_piece_input
    game_output.text_message(:promotion_prompt)
    loop do
      valid_promotions = %w[queen q rook r bishiop b knight n]
      response = gets.chomp.downcase
      new_piece = response[0]
      return new_piece if valid_promotions.include? response

      game_output.text_message(:invalid_promotion)
    end
  end

  def quit_game
    @end_game = 'quit'
    nil
  end

  # change to have @winner and @end_game be any?
  def end_game?
    return true if @end_game

    conditions = players.map { |player| game_validator.end_game_conditions?(player, last_piece) }
    @end_game, @winner = game_over_type(conditions)
    end_game != false
  end

  def game_over_type(conditions)
    sym = conditions.select { |cond| cond.is_a? Symbol }.shift
    type = (sym or false)
    loser_index = conditions.index(type)
    winner_index = loser_index - 1
    winning_colour = players[winner_index]
    [type, winning_colour]
  end

  def game_over_message
    case end_game
    when 'quit'
      game_output.text_message(:quit_msg, nil, false)
    when :mated
      game_output.text_message(:checkmate_msg, winner, false)
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
    seralised_obj = JSON.dump(
      {
        board: game_board.board,
        players: player_order,
        theme: game_output.theme,
        board_history: game_output.board_history_stack
      }
    )
    file_name = obtain_file_name
    File.open("saves/#{file_name}", 'w') { |file| file.puts seralised_obj }
  end

  def player_order
    active_player == :white ? %i[white black] : %i[black white]
  end

  def obtain_file_name
    loop do
      game_output.text_message(:file_name_prompt)
      fname = gets.chomp.downcase
      next if fname.length < 2

      existing = File.exist?("saves/#{fname}")
      return fname unless existing

      game_output.text_message(:overwrite_prompt)
      overwrite = gets.chomp.downcase
      return fname if %w[y yes].include? overwrite
    end
  end

  def input_messages(destination)
    if destination
      game_output.text_message(:destination_prompt, active_player)
    else
      game_output.text_message(:selection_prompt, active_player)
    end
  end

  def valid_input?(input)
    return true if COMMANDS.include? input

    game_translator.focus_on(input)
    game_translator.valid_notation?
  end

  # Interface with Board class
  def label_piece(coords)
    validator.label_square(coords, active_player)
  end

  def process_input(input = nil)
    # quick_move translations
    game_translator.translate_location(input)
  end
end
