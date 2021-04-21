# frozen-string-literal: true

# Movement validation including check and checkmate, interfacing with spectator
class MoveValidator

  attr_reader :current_board, :spectator#, :past_board

  def initialize(board, spectator = Spectator.new)
    @current_board
    @spectator = spectator
    # @kings = {}
  end

  def take_board_snapshot(board)
    # @past_board = current_board
    @current_board = board
    @spectator.get_current_board(current_board)
  end

  def find_king(colour = nil)
    king_list = spectator.scan_board_for_piece(King)
    king_list.select { |king| king.colour == colour } unless colour.nil?
  end

  def identify_pieces_in_king_direction
    current_king = find_king
    spectator.update_location(*current_king.location)
    spectator.scan_around_location
  end

  def check?(colour)
    pieces_in_king_direction = identify_pieces_in_king_direction
  end

  def checkmate?
    # check?
  end

end