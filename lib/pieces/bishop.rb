# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Bishop < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3.5
    @directions = [[1, 1], [-1, -1], [-1, 1], [1, -1]].freeze
    @symbol = "\u265D"
  end
end
