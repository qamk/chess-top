# frozen-string-literal: true

require_relative 'board'
require_relative 'rules/movement'

# Reads files and ranks to look for pieces
class Spectator

  piece_selector = ->(list) { list.select { |element| element.is_a? Piece } }

  attr_reader :location, :mover, :board, :spec_directions
  def initialize(mover = Movement.new, board = nil)
    @mover = mover
    @location = { rank: 0, file: 0 }
    @board = board
    @spec_directions = []
  end

  def update_location(location)
    @location = location
  end

  # Returns the pieces in the spectator's file
  def scan_file_at_location
    file_list = extract_file
    file_at_location = file_list[location[:file]]
    pieces_in_file = piece_selector.call(file_at_location)
  end

  # Returns the pieces in the spectator's rank
  def scan_rank_at_location
    rank_list = board[location[:rank]]
    pieces_in_rank = piece_selector.call(rank_list)
  end
  
  # Returns the pieces in the spectator's diagonal
  def scan_diagonal
    location_array = location.values
    local_directions = [[1, 1], [-1, 1]]
    mover.find_all_legal_moves(7, location_array, local_directions)
  end
  
  # Simulates movement in given directions
  def simulate_movement(destination, colour)
    # preted to be at the destination, reverse the movement and see if the correct kind of piece is there
  end

  private

  def extract_file
    transformed_grid = []
    (0..6).each do |file_index|
      file = []
      board.each do |rank|
        file.push(rank[file_index])
      end
      transformed_grid.push(file)
    end
    transformed_grid
  end


end