# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Knight < Piece
  def initialize(colour)
    super(colour)
    @value = 3
    freeze
  end

  def direction_list
    @directions = [[2, 1], [1, 2], [-2, 1], [-1, 2]].freeze
  end

end