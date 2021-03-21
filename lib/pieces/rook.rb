# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Rook < Piece
  def initialize(colour)
    super(colour)
    @value = 3
    freeze
  end

  def direction_list
    @directions = [[1, 0], [0, 1]].freeze
  end

end