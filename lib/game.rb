# frozen-string-literal: true

# rubocop: disable Metrics/ClassLength

require 'json'
require 'pry'

# Handles input and general game functions
class Game
  attr_reader :game_translator, :game_output, :game_board,
              :game_spectator, :game_validator, :players, :quit,
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
    @quit = false
    @winner = nil
  end

  def start
    game_board.create_starting_board
    snapshots
    play
  end

  def snapshots
    game_output.take_snapshot(game_board.board)
    game_output.obtain_current_piece(last_piece)
    game_validator.take_board_snapshot(game_board.board)
  end

  def play
    game_start until end_game
    game_over_message
  end

  def game_start
    players.cycle(2) do |player|
      break if end_game?

      @active_player = player
      selection = selection_processes
      break if end_game

      movement_processes(selection)
      promotion_check(selection) unless end_game?
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
      movement_messages(:check) if game_validator.king_in_check?(active_player)
      input = obtain_validate_input
      return quit_game if input =~ /\s*quit\s*/

      if COMMANDS.include? input
        handle_commands(input)
        next
      end

      selected_piece = piece_can_move?(input)
      return selected_piece[-1] if selected_piece.is_a? Array
      
      selection_messages(selected_piece)
    end
  end
  
  def piece_can_move?(input)
    processed = process_input(input)
    label, piece = label_location(processed)
    return if piece.nil?

    game_validator.plot_available_moves(piece)
    [label, piece] unless piece.available_moves.empty?
  end

  def selection_messages(key)
    if key == :hostile
      game_output.text_message(:hostile_selection, nil, false)
    else
      game_output.text_message(:empty_selection, nil, false)
    end
  end

  def movement_processes(selection)
    game_output.obtain_current_piece(selection)
    game_output.display_game_state

    make_move(selection)
    game_output.clear_current_piece
  end

  def make_move(piece, destination = '')
    loop do
      can_move, destination = validate_move(piece)
      break if (can_move == true) || end_game

      movement_messages(can_move) unless can_move.nil?
    end
    return if end_game

    @last_piece = piece
    snapshots
    game_board.update_board(piece, destination)
    en_passant_update(piece, destination) if piece.is_a? Pawn
  end

  def en_passant_update(piece, destination)
    contents = label_location(destination)
    return unless contents == :empty

    rank, file = piece.location
    forward, * = piece.directions[0]
    piece_to_remove = game_board.board[(rank - forward)][file]
    return if piece_to_remove.nil? || piece_to_remove.colour == piece.colour

    game_board.en_passant_cleanup(piece_to_remove)
  end

  def movement_messages(tag)
    movement_issues = {
      check: [:check_msg, active_player, false],
      ally: [:ally_occupied, nil, false],
      no_castle: [:invalid_castle, nil, false],
      no_en_passant: [:invalid_en_passant, nil, false],
      not_in_moveset: [:invalid_destination, nil, false]
    }
    method_details = movement_issues[tag]
    game_output.text_message(*method_details)
  end

  def validate_move(piece)
    destination_input = obtain_validate_input(true)
    return quit_game if destination_input =~ /\s*quit\s*/

    destination = process_input(destination_input)

    return handle_commands(destination_input) if COMMANDS.include? destination_input

    meta_info = obtain_meta_info(piece, destination)
    valid_move = move_is_valid?(piece, destination, meta_info)

    return valid_move if valid_move == :ally

    return :check if check_after_move?(piece, destination)

    [valid_move, destination]
  end

  def check_after_move?(piece, destination)
    game_board.update_pseudo_board(piece, destination)
    game_validator.take_board_snapshot(game_board.pseudo_board)
    game_validator.king_in_check?(active_player)
  end

  def obtain_meta_info(piece, destination)
    { category: categorise_move(piece, destination), contents: label_location(destination) }
  end

  def categorise_move(piece, destination)
    return :castling if castling_on_starting_rank?(piece, destination)

    :normal
  end

  def move_is_valid?(piece, destination, meta_info)
    return :ally if meta_info[:contents].is_a? Array

    category = meta_info[:category]
    method = category == :normal ? :validate_normal_move? : :validate_castling_move
    send(method, piece, destination, meta_info)
  end

  def validate_castling_move(piece, destination, *)
    castle = game_validator.castling(piece, destination)
    return :no_castle unless castle

    game_board.update_castle(castle)
    true
  end

  def castling_on_starting_rank?(piece, destination)
    return false unless piece.is_a? King

    # =====================
    ref_rank = piece.colour == :white ? 7 : 0
    rank, file = piece.location
    directions = [[0, 1], [0, -1]]
    castle_direction = game_validator.calculate_castle_direction([rank, file], destination, directions)
    castle_direction && (rank == ref_rank) && (destination[0] == ref_rank)
  end

  def validate_normal_move?(piece, destination, meta_info)
    contents = meta_info[:contents]
    return :not_in_moveset unless piece.available_moves.include?(destination)

    %i[empty hostile].include?(contents)
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
    @end_game = true
    @quit = true
    nil
  end

  # change to have @winner and @end_game be any?
  def end_game?
    return true if quit == true

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
    return game_output.text_message(:quit_msg, nil, false) if quit

    case end_game
    when :mated
      game_output.text_message(:checkmate_msg, winner, false)
    else
      game_output.text_message(:stalemate_msg, nil, false)
    end
  end

  def handle_commands(command)
    command_methods = { 'commands' => :commands, 'save' => :serialise }
    send(command_methods[command])
    nil
  end

  def commands
    game_output.text_message(:command_list_msg)
    game_output.display_game_state
  end

  def serialise
    seralised_obj = JSON.dump(
      {
        board: format_board(game_board.board),
        players: player_order,
        theme: game_output.theme,
        board_history: game_output.board_history_stack
      }
    )
    file_name = obtain_file_name
    Dir.mkdir 'saves' unless Dir.exist? 'saves'
    File.open("saves/#{file_name}.json", 'w') { |file| file.puts seralised_obj }
  end

  def format_board(board)
    board.map.with_index do |rank|
      rank.map do |square|
        next if square.nil?

        piece_name = square.class
        colour = square.colour
        "#{piece_name}:#{colour}"
      end
    end
  end

  def player_order
    active_player == :white ? %i[white black] : %i[black white]
  end

  def obtain_file_name(fname = '')
    loop do
      game_output.text_message(:file_name_prompt)
      fname = gets.chomp.downcase
      return if fname =~ /\s*q(uit)?\s*/
      next if fname.length < 2

      existing = File.exist?("saves/#{fname}.json")
      break unless existing

      game_output.text_message(:overwrite_prompt)
      overwrite = gets.chomp.downcase
      break fname if %w[y yes].include? overwrite
    end
    puts 'Saved!'
    fname
  end

  def load(save)
    @game_board.load_board(save['board'])
    @players = save['players'].map(&:to_sym)
    @game_output.change_theme(save['theme'])
    game_output.import_history(save['board_history'])
    snapshots
  end

  def input_messages(destination)
    if destination
      game_output.text_message(:destination_prompt, active_player, false)
    else
      game_output.text_message(:selection_prompt, active_player, false)
    end
  end

  def valid_input?(input)
    return true if COMMANDS.include? input

    game_translator.valid_notation?(input)
  end

  def label_location(coords)
    game_validator.label_square(coords, active_player)
  end

  def process_input(input = nil)
    # quick_move translations
    game_translator.translate_location(input)
  end
end
