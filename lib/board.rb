# frozen-string-literal: true

require_relative './rules/movement'
require_relative './rules/move_validation'

# Mechanics for interacting with the chess board
class ChessBoard
  attr_reader :board
  def initialize(board = Array.new(8) { Array.new(8) }, args = {})
    @board = board
    @movement = args[:movement]
    @theme = args[:theme]
    
  end


end