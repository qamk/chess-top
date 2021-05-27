# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Rook class
class Rook < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3
    @directions = [[1, 0], [-1, 0], [0, 1], [0, -1]].freeze
    @symbol = "\u265C"
  end
end