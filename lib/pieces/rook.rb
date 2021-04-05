# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Rook < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3
  end

  def direction_list
    @directions = [[1, 0], [0, 1]].freeze
  end

end