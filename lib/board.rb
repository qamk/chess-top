# frozen-string-literal: true

require_relative './rules/movement'
require_relative './rules/move_validation'

# Mechanics for interacting with the chess board
class ChessBoard
  attr_reader :board
  def initialize(board = Array.new(8) { Array.new(8) }, args = {})
    @board = board
    @movement = args[:movement]
    @board_theme = args[:theme]
  end

  def create_starting_board
    pawn_location = [[1, :black], [6, :white]]
    unique_pieces_location = [[0, :black], [7, :white]]
    pawn_location.each { |row, colour| pawn_row(row, colour) }
    unique_pieces_location.each { |row, colour| unique_pieces_row(row, colour) }
  end

  def unique_pieces_row(row, colour)
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

  def pawn_row(row, colour)
    file = [0, 1, 2, 3, 4, 5, 6, 7]
    @board[row].map { Pawn.new(colour, [row, file.shift]) }
  end

end
