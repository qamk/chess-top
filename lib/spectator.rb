# frozen-string-literal: true

require_relative 'board'
require_relative 'rules/movement'
require_relative 'pieces/general'

# Reads files and ranks to look for pieces
class Spectator

  def piece_selector(list)
    list.select { |element| element.is_a? Piece }
  end

  attr_reader :location, :mover, :board
  def initialize(mover = Movement.new)
    @mover = mover
    @location = { rank: 0, file: 0 }
  end

  def get_current_board(board)
    @board = board.dup
  end

  def update_location(location)
    rank, file = location
    @location[:rank] = rank
    @location[:file] = file
  end

  def scan_around_location
    [scan_file_at_location, scan_rank_at_location,
     scan_diagonal_at_location, scan_for_knight_at_location].flatten
  end

  def scan_for_knight_at_location
    knight_directions = [
      [2, 1], [1, 2], [-2, 1], [-1, 2],
      [-2, -1], [-1, -2], [2, -1], [1, -2]
    ]
    coords = mover.find_all_legal_moves(1, true, location.values, knight_directions)
    knights = coords.map { |rank, file| board[rank][file] }
    piece_selector(knights)
  end

  # Returns the pieces in the spectator's file
  def scan_file_at_location
    file_list = extract_file
    file_at_location = file_list[location[:file]]
    pieces_in_file = piece_selector(file_at_location)
  end

  # Returns the pieces in the spectator's rank
  def scan_rank_at_location
    rank_list = board[location[:rank]]
    pieces_in_rank = piece_selector(rank_list)
  end
  
  # Returns the pieces in the spectator's diagonal
  def scan_diagonal_at_location
    location_array = location.values
    local_directions = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
    coords = mover.find_all_legal_moves(20, true, location_array, local_directions)
    diagonals_list = coords.map { |rank, file| board[rank][file] }
    pieces_in_diagonal = piece_selector(diagonals_list)
  end

  def scan_board_for_piece(piece)
    board.flatten.select { |item| item.is_a? piece }
  end
  
  # Simulates movement in given directions
  def simulate_movement(destination, colour)
    # preted to be at the destination, reverse the movement and see if the correct kind of piece is there
  end

  private

  def extract_file
    transformed_grid = []
    (0..7).each do |file_index|
      file = []
      board.each do |rank|
        file.push(rank[file_index])
      end
      transformed_grid.push(file)
    end
    transformed_grid
  end


end