# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Knight < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3
    @directions = [
      [2, 1], [1, 2], [-2, 1], [-1, 2],
      [-2, -1], [-1, -2], [2, -1], [1, -2]
    ].freeze
  end

end