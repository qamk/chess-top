# frozen-string-literal: true

# Movement validation including check and checkmate, interfacing with spectator
class MoveValidator

  attr_reader :current_board, :spectator#, :past_board

  def initialize(board, spectator = Spectator.new, mover = Movement.new)
    @current_board
    @spectator = spectator
    @mover = mover
    # @kings = {}
  end

  # Take a look at the current board
  def take_board_snapshot(board)
    # @past_board = current_board # potentially for an intelligent computer
    @current_board = board
    @spectator.get_current_board(current_board)
  end

  # Returns the specified King (or both Kings if unspecified)
  def find_king(colour = nil)
    king_list = spectator.scan_board_for_piece(King)
    king_list.select { |king| king.colour == colour } unless colour.nil?
  end

  # Returns pieces around a target (piece or location)
  def identify_pieces_around_target(target)
    target = target.is_a?(Piece) ? target.location : target
    spectator.update_location(*target)
    spectator.scan_around_location
  end

  # Returns the opposition pieces that are "looking" at the target
  def identify_target_locking_candidates(target, colour)
    pieces_around_target = identify_pieces_around_target(target)
    # clean up empty nested arrays
    in_direction = pieces_around_target.select { |piece| square_in_right_direction?(piece, target.location) }
    in_direction.reject { |piece| piece.colour == colour }
  end

  # Returns the path of each piece "looking" at the target
  def in_sight(target, candidates, coords_only = false)
    candidate_direction_to_target = direction_to_target_index(candidates, target)
    # find all legal moves in that direction
    candidate_direction_pair = candidates.zip(candidate_direction_to_target)
    candidate_perspectives = candidate_direction_pair.map { |cand, dirc| mover.find_all_legal_moves(7, cand.location, dirc, false) }
    return candidate_perspectives if coords_only

    candidate_perspectives.map { |persp| persp.map { |rank, file| current_board[rank][file] } }
  end

  # True if King is in check
  def king_in_check?(colour)
    king = find_king(colour)
    check?(king, colour)
  end
  
  # True if pieces have an unobstructed view of target
  def check?(target, colour)
    candidates = identify_target_locking_candidates(target, colour)
    candidate_viewpoints = in_sight(target, candidates)
    candidate_viewpoints.any? { |view| view.one? { |square| square.is_a? Piece } }
  end

  # True King has no valid moves and checking pieces cannot be captured
  def checkmate?(colour)
    return false unless king_in_check?(colour)

    king = find_king(colour)
    moves = king.available_moves.map { |rank, file| current_board[rank][file] }
    candidates = moves.map { |move| identify_target_locking_candidates(move, colour) }
    return false if no_way_out?(moves, candidates)

    candidates.any? { |cand| check?(cand, colour) }
  end

  # True if any move has a potential capture
  def no_way_out?(moves, candidates)
    move_candidate_pair = moves.zip(candidates)
    viewpoint_coords = move_candidate_pair.map { |move, cand| in_sight(move, cand, true) }
    moves.all? { |move| viewpoint_coords.any? { |view| view.include? move } }
  end
  
  # Identify which direction the pieces are facing
  def direction_to_target_index(candidates, target)
    direction_indices_to_target = candidates.map { |cand| square_in_right_direction?(cand, target.directions, true) }
    # direction_indices_to_king = unclean_direction_indices_to_king.map { |index| index.empty? ? :wrong_direction : index }
    paired_indices_pieces = direction_indices_to_target.flatten.zip(candidates)
    paired_indices_pieces.map { |index, piece| [piece.directions[index]] }
  end

  # ---------- Also for a version with quick move sorted ----------

  def square_in_right_direction?(piece, destination, report_direction = false)
    change_in_position = calculate_component_difference([piece.location, destination].transpose) # handle in other method
    scaler_list = calculate_scalers(piece.directions, change_in_position)
    return valid_scalers?(scaler_list) unless report_direction

    valid_scalers?(scaler_list, report_direction)
  end

  # The final check whether a destination is in the direction of some piece
  def valid_scalers?(scalers, report_direction = false)
    return scalers.any? { |scaler| scaler.uniq.count == 1 } unless report_direction

    scalers.map { |scaler| scalers.index(scaler) if scaler.uniq.count == 1 }.compact
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

end