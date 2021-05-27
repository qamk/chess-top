# frozen-string-literal: true

require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

# Mechanics for interacting with the chess board
class Board
  attr_reader :board, :old_board, :pseudo_board, :move_validator
  def initialize(board = Array.new(8) { Array.new(8) })
    @board = board
    @pseudo_board = nil
    @old_board = board
  end

  def create_starting_board
    pawn_location = [[1, :black], [6, :white]]
    unique_pieces_location = [[0, :black], [7, :white]]
    pawn_location.each { |rank, colour| create_pawn_rank(rank, colour) }
    unique_pieces_location.each { |rank, colour| create_unique_pieces_rank(rank, colour) }
  end

  def copy(obj)
    Marshal.load(Marshal.dump(obj))
  end

  def create_unique_pieces_rank(rank, colour)
    @board[rank] = [
      Rook.new(colour, [rank, 0]),
      Knight.new(colour, [rank, 1]),
      Bishop.new(colour, [rank, 2]),
      Queen.new(colour, [rank, 3]),
      King.new(colour, [rank, 4]),
      Bishop.new(colour, [rank, 5]),
      Knight.new(colour, [rank, 6]),
      Rook.new(colour, [rank, 7])
    ]
  end

  def create_pawn_rank(rank, colour)
    file = [0, 1, 2, 3, 4, 5, 6, 7]
    @board[rank] = (0..7).map { Pawn.new(colour, [rank, file.shift]) }
  end

  def promote(pawn, new_piece)
    pieces = { q: Queen, r: Rook, b: Bishop, n: Knight }
    pawn_rank, pawn_file = pawn.location
    board[pawn_rank][pawn_file] = pieces[new_piece].new(pawn.colour, pawn.location)
  end

  def load_board(imported_board)
    pieces = {
      'Rook' => Rook, 'Bishop' => Bishop, 'Knight' => Knight,
      'Queen' => Queen, 'King' => King, 'Pawn' => Pawn
    }
    @board = imported_board
    board.each_with_index do |rank, r_index|
      rank.each_with_index do |square, f_index|
        next if square.nil?

        name, colour = square.split(':')
        piece = pieces[name]
        p_colour = colour.to_sym
        @board[r_index][f_index] = piece.new(p_colour, [r_index, f_index])
      end
    end
  end

  def en_passant_cleanup(piece)
    rank, file = piece.location
    @board[rank][file] = nil
  end

  def update_castle(destination)
    old_rank, old_file, new_rank, new_file = destination
    piece = board[old_rank][old_file]
    new_destination = [new_rank, new_file]
    update_board(piece, new_destination)
  end

  def update_pseudo_board(piece, destination)
    @pseudo_board = copy(board)
    old_rank, old_file = piece.location
    new_rank, new_file = destination
    @pseudo_board[new_rank][new_file] = piece
    @pseudo_board[old_rank][old_file] = nil
  end
  
  def update_board(piece, destination)
    old_rank, old_file = piece.location
    new_rank, new_file = destination
    @board[new_rank][new_file] = piece
    @board[old_rank][old_file] = nil
    piece.update_location(destination)
  end
end
