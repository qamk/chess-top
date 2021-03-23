# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class King < Piece
  def initialize(colour)
    super(colour)
    @value = 100
  end

  def direction_list
    @directions = [[1, 1], [-1, 1], [1, 0], [0, 1]].freeze
  end

end