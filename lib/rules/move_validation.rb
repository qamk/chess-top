# frozen-string-literal: true

# rubocop: disable Metrics/ClassLength

require_relative 'movement'
require_relative './../spectator'

# Movement validation including check and checkmate, interfacing with spectator
class MoveValidator
  def right_target(target)
    target.is_a?(Piece) ? target.location : target
  end
  attr_reader :current_board, :spectator, :past_board, :mover

  def initialize(board, spectator = Spectator.new, mover = Movement.new)
    @current_board = board
    @spectator = spectator
    @mover = mover
  end

  def end_game_conditions?(colour, last_piece)
    if checkmate?(colour, last_piece)
      :mated
    elsif stalemate?(colour)
      :stalemate
    else
      false
    end
  end

  # clean pawn path to remove diagonals unless a piece is present
  def plot_available_moves(piece)
    # negate = false if piece.is_a? Pawn
    valid_moves = unblocked_path(piece)
    piece.update_available_moves(valid_moves)
  end

  # Take a look at the current board
  def take_board_snapshot(board)
    @past_board = current_board.dup
    @current_board = board.dup
    @spectator.get_current_board(current_board)
  end

  # Returns the specified King (or both Kings if unspecified)
  def find_king(colour = nil)
    king_list = spectator.scan_board_for_piece(King)
    return king_list if colour.nil?

    king_list.select { |king| king.colour == colour }
  end

  # Returns pieces around a target (piece or location)
  def identify_pieces_around_target(target)
    target = right_target(target)
    spectator.update_location(target)
    spectator.scan_around_location
  end

  # Returns the opposition pieces that are "looking" at the target
  def identify_target_locking_candidates(target, colour)
    target = right_target(target)
    pieces_around_target = identify_pieces_around_target(target)
    in_direction = pieces_around_target.select { |piece| square_in_right_direction?(piece, target) }
    in_direction.reject { |piece| piece.colour == colour }
  end

  # Returns the path of each piece "looking" at the target
  def sight(target, candidates, coords_only = false)
    candidate_direction_to_target = direction_to_target(target, candidates)
    unclean_candidate_direction_pair = candidates.zip(candidate_direction_to_target)
    # clean pawns here unless pawn is looking at index [1, 1], [-1, 1]
    candidate_direction_pair = only_attacking(target, unclean_candidate_direction_pair)
    candidate_perspectives = candidate_direction_pair.map { |cand, dirc| mover.find_all_legal_moves(14, false, cand.location, dirc) }
    return candidate_perspectives if coords_only

    candidate_perspectives.map { |persp| persp.map { |rank, file| current_board[rank][file] } }
  end

  # Returns only the pawns that are attacking
  def only_attacking(target, candidate_direction_pair)
    difference = proc { |a, b| b - a }
    target = right_target(target)
    candidate_direction_pair.select do |candidate, _|
      next(true) unless [King, Pawn].include? candidate.class

      colour = candidate.colour
      components = [candidate.location, target].transpose
      distance = components.map { |component| difference.call(component) }
      attacking(candidate, colour, distance)
    end
  end

  def attacking(piece, colour, distance)
    attacking_pawn = { black: [[1, 1], [1, -1]], white: [[-1, -1], [-1, 1]] }
    attacking_king = [
      [1, 1], [-1, 0], [-1, 1], [1, -1],
      [1, 0], [-1, -1], [0, 1], [0, -1]
    ]
    piece.is_a?(King) ? attacking_king.include?(distance) : attacking_pawn[colour].include?(distance)
  end

  # True if King is in check
  def king_in_check?(colour)
    king = find_king(colour)[0]
    check?(king, colour)
  end

  # True if pieces have an unobstructed view of another piece
  def check?(target, target_colour)
    coords_only = target.is_a? Array
    candidates = identify_target_locking_candidates(target, target_colour)
    candidate_viewpoints = sight(target, candidates, coords_only)
    return pseudo_check?(candidate_viewpoints, target) if coords_only

    candidates_first_piece = candidate_viewpoints.map { |view| view.select { |square| square.is_a? Piece } }.map(&:first)
    candidates_first_piece.any? { |first_piece| first_piece == target }
  end

  def pseudo_check?(viewpoints, target)
    moveable = viewpoints.map do |view|
      view.select do |rank, file|
        next(true) if target == [rank, file]

        next(true) if current_board[rank][file].is_a? Piece

        false
      end
    end
    moveable.any? { |view| view&.first == target }
  end

  # True King has no valid moves and checking pieces cannot be captured
  def checkmate?(colour, last_piece)
    return false unless king_in_check?(colour)

    king = find_king(colour)[0]
    last_colour = last_piece.colour
    plot_available_moves(king)
    moves = king.available_moves
    return false if block_last_piece?(king, last_piece, last_colour)

    no_way_out?(moves, colour) && check?(last_piece, last_colour)
  end

  # True if the last moved piece can have its check blocked
  def block_last_piece?(king, last_piece, last_colour)
    last_piece_sight = sight(king, [last_piece], true)[0]
    last_check_squares = last_piece_sight.select { |square| check?(square, last_colour) }
    final_sight = last_check_squares - king.available_moves
    !final_sight.empty?
  end

  # True if the chessboard is in stalemate
  def stalemate?(colour)
    return false if king_in_check?(colour)

    king = find_king(colour)[0]
    plot_available_moves(king)
    moves = king.available_moves
    no_way_out?(moves, colour)
  end

  # True if all moves have a potential capture
  def no_way_out?(moves, colour)
    moves.all? { |move| check?(move, colour) }
  end
 
  # Identify which direction the opponent pieces are facing
  def direction_to_target(target, candidates)
    target = right_target(target)
    direction_indices_to_target = candidates.map { |cand| square_in_right_direction?(cand, target, true) }
    paired_indices_pieces = direction_indices_to_target.flatten.zip(candidates)
    paired_indices_pieces.map { |index, piece| [piece.directions[index]] }
  end

  # Returns the unobstructed path of piece
  def unblocked_path(piece)
    mover.focus_on(piece)
    full_path = mover.normal_move
    return full_path if %w[Knight King].include? piece.class.to_s

    path_on_board = full_path.map { |rank, file| current_board[rank][file] }
    other_pieces_in_path = find_other_pieces(path_on_board)
    return [] if other_pieces_in_path.empty?

    path_beyond_other_pieces = extending_beyond_other_pieces(piece, other_pieces_in_path)
    remove_mutual_path(piece, full_path, path_beyond_other_pieces, other_pieces_in_path)
  end

  # Returns list in main path that is not in other_pieces_path
  def remove_mutual_path(piece, full_path, other_pieces_path, other_pieces)
    main_path = remove_friendly(piece, other_pieces, full_path)
    joined_other_pieces_path = other_pieces_path.reduce([], :concat)
    final_path = main_path - joined_other_pieces_path
    return final_path unless piece.is_a? Pawn

    final_path - invalid_pawn_moves(main_path, piece)
  end

  def remove_friendly(piece, others, full_path)
    colour = piece.colour
    friendly_location = others.select { |other| other.colour == colour }.map(&:location)
    full_path - friendly_location
  end

  # Returns a list of invalid moves derived from a pawn's possible moves
  def invalid_pawn_moves(main_path, pawn)
    move_coords = main_path
    move_validity = find_pawn_moves_to_keep(move_coords, pawn)
    move_coords.reject.with_index { |_, index| move_validity[index] }
  end

  # Returns the pawn moves that are valid
  def find_pawn_moves_to_keep(moves, pawn)
    colour = pawn.colour
    move_contents = moves.map { |move| label_square(move, colour) }
    move_contents.map.with_index do |content, index|
      case index
      when 1
        pawn_not_moved?(pawn) && (content == :empty)
      else
        content == :hostile
      end
    end
  end

  # Returns other pieces in a given path
  def find_other_pieces(path)
    path.select do |piece|
      next(false) if piece.nil?

      true
    end
  end

  # Obtains the path of "piece" that should be obstructed by "other_pieces"
  def extending_beyond_other_pieces(piece, other_pieces)
    direction_of_other_pieces_indices = other_pieces.map { |others| square_in_right_direction?(piece, others.location, true)[0] }
    path_beyond(piece.directions, other_pieces, direction_of_other_pieces_indices)
  end

  def path_beyond(direction_ref, other_pieces, others_indices)
    direction_of_other_pieces = others_indices.map { |index| [direction_ref[index]] }
    other_pieces_direction_pair = other_pieces.zip(direction_of_other_pieces)
    other_pieces_direction_pair.map { |others, direction| mover.find_all_legal_moves(25, false, others.location, direction) }
  end

  def pawn_move(pawn, destination, contents)
    return false if contents == :friendly

    direction = square_in_right_direction?(pawn, destination, true)[0]
    case direction
    when 0
      contents == :empty
    when 1
      pawn_not_moved?(pawn)
    else
      contents == :hostile
    end
  end

  def en_passant?(piece, destination, contents)
    adjacent_piece, adjacent_file = obtain_adjacent_piece(piece, destination)
    present_condiions_met = possible_en_passant?(piece, contents, adjacent_piece)
    present_condiions_met ? past_pawn_double_move?(piece, adjacent_file) : false
  end

  # True if the initial conditions have been met for en_passant
  def obtain_adjacent_piece(pawn, destination)
    pawn_rank, pawn_file = pawn.location
    direction_index = pawn_diagonal(pawn.location, destination, pawn.directions)
    return false if direction_index.nil?

    file_direction = pawn.directions[direction_index][-1]
    adjacent_file = pawn_file + file_direction
    adjacent_piece = current_board[pawn_rank][adjacent_file]
    [adjacent_piece, adjacent_file]
  end

  def pawn_diagonal(location, destination, directions)
    component_match = [location, destination].transpose
    difference = calculate_component_difference(component_match)
    directions.index(difference) unless [2, 0].include? difference
  end

  def possible_en_passant?(pawn, destination_contents, adjacent_piece)
    return false unless (destination_contents == :empty) && adjacent_piece.is_a?(Pawn)

    adjacent_piece.colour != pawn.colour
  end

  # False unless an enemy pawn made a double move from their starting rank
  def past_pawn_double_move?(pawn, adjacent_file)
    starting_rank = pawn.colour == :white ? 1 : 6
    past_starting_rank = past_board[starting_rank][adjacent_file]
    return false unless past_starting_rank.is_a? Pawn

    past_starting_rank.colour == pawn.colour ? false : :en_passant_move
  end

  # True if a pawn is not on its starting rank
  def pawn_not_moved?(pawn)
    starting_rank = pawn.colour == :white ? 6 : 1
    pawn.location[0] == starting_rank
  end

  # True if King can be castled
  def castling(king, destination)
    directions = [[0, 1], [0, -1]]
    castle_direction_index = calculate_castle_direction(king.location, destination, directions)
    castle_direction = directions[castle_direction_index]
    castle_coords = mover.find_all_legal_moves(7, false, king.location, [castle_direction])
    return false unless valid_castle?(king.colour, castle_coords, castle_direction)

    calculate_rook_destination(destination, castle_direction)
  end

  def calculate_rook_destination(king_destination, direction)
    current_rook_file = direction == [0, 1] ? 7 : 0
    *, file = direction
    king_rank, king_file = king_destination
    new_rook_file = king_file + (file * -1)
    [king_rank, current_rook_file, king_rank, new_rook_file]
  end

  def calculate_castle_direction(location, destination, directions)
    component_vectors = [location, destination].transpose
    difference = calculate_component_difference(component_vectors)
    return false unless [2, -3].include? difference[-1]

    vertical_horizontal?(difference, directions, true)[0]
  end

  # True if King can move to castle
  def valid_castle?(colour, coords, direction)
    castle_rank = colour == :white ? 7 : 0
    rook_file = direction == [0, 1] ? 7 : 0
    return false unless current_board[castle_rank][rook_file].is_a? Rook

    coords_up_to_rook = coords.reject { |rank, file| current_board[rank][file].is_a? Rook }
    coords_up_to_rook.none? { |coord| check?(coord, colour) }
  end

  # True if a destination is in the direction of a piece
  def square_in_right_direction?(piece, destination, report_direction = false)
    change_in_position = calculate_component_difference([piece.location, destination].transpose) # handle in other method
    return vertical_horizontal?(change_in_position, piece.directions, report_direction) if one_dimensional_movement?(change_in_position)

    scaler_list = calculate_scalers(piece.directions, change_in_position)
    return valid_scalers?(scaler_list) unless report_direction

    valid_scalers?(scaler_list, report_direction)
  end

  def one_dimensional_movement?(change)
    change.one?(&:zero?)
  end

  def vertical_horizontal?(change, directions, report_direction)
    dirc = ->(list, divisor) { list.map { |val| val / divisor } }
    non_zero = change.reject(&:zero?).shift.abs
    calculated_direction = dirc.call(change, non_zero)
    return directions.include? calculated_direction unless report_direction

    [directions.index(calculated_direction)]
  end

  # The final check whether a destination is in the direction of some piece
  def valid_scalers?(scalers, report_direction = false)
    valid = proc { |rank, file| (rank == file) && rank.positive? }
    return scalers.any? { |scaler| valid.call(scaler) } unless report_direction

    scalers.map { |scaler| scalers.index(scaler) if valid.call(scaler) }.compact
  end

  def calculate_scalers(directions, delta_position)
    scaler = proc { |a, b| b.zero? ? 0 : a / b }
    directions.map do |direction|
      component_match = [delta_position, direction].transpose
      component_match.map { |component| scaler.call(component) }
    end
  end

  def calculate_component_difference(component_vectors)
    difference = proc { |a, b| b - a }
    difference = component_vectors.map { |component| difference.call(component) }
  end

  def label_square(coords, colour)
    square_contents = current_board[coords[0]][coords[1]]
    validity = valid_selection?(square_contents, colour)
    case validity
    when nil
      :empty
    when true
      [:friendly, square_contents]
    else
      :hostile
    end
  end

  def valid_selection?(square_contents, colour)
    return nil unless square_contents.respond_to? :colour

    square_contents.colour == colour
  end
end
