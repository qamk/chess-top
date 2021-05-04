# frozen-string-literal: true

require_relative './rules/movement'
require_relative './rules/move_validation'
# Import pieces

# Mechanics for interacting with the chess board
class ChessBoard
  attr_reader :board, :move_validator
  def initialize(board = Array.new(8) { Array.new(8) }, args = {})
    @board = board
    @move_validator = args[:move_validator]
    @board_theme = args[:theme]
  end

  def create_starting_board
    pawn_location = [[1, :black], [6, :white]]
    unique_pieces_location = [[0, :black], [7, :white]]
    pawn_location.each { |row, colour| create_pawn_row(row, colour) }
    unique_pieces_location.each { |row, colour| create_unique_pieces_row(row, colour) }
  end

  def create_unique_pieces_row(row, colour)
    @board[row] = [
      Rook.new(colour, [row, 0]),
      Knight.new(colour, [row, 1]),
      Bishop.new(colour, [row, 2]),
      Queen.new(colour, [row, 3]),
      King.new(colour, [row, 4]),
      Bishop.new(colour, [row, 5]),
      Knight.new(colour, [row, 6]),
      Rook.new(colour, [row, 7])
    ]
  end

  def create_pawn_row(row, colour)
    file = [0, 1, 2, 3, 4, 5, 6, 7]
    @board[row].map { Pawn.new(colour, [row, file.shift]) }
  end

  # display valid_locations like in normal chess apps
  def plot_available_moves(piece, negate = true)
    negate = false if piece.is_a? Pawn
    valid_locations = move_validator.unblocked_path(piece, negate)
    piece.update_available_moves(valid_locations)
  end

  # Create a spectator class that looks along a file/rank/diag
  # def quick_move?(piece, coords)
  #   movement.focus_on(piece).perform_quick_move(coords)
  # end

  def select_square(coords, colour)
    square_contents = [coords[0], coords[1]]
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

  def update_board(piece, destination)
    old_row, old_col = piece.location
    new_row, new_col = destination
    @board[new_row][new_col] = piece
    @board[old_row][old_col] = nil
    piece.update_location(destination)
  end

end
