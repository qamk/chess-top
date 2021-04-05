# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Queen < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3.5
  end

  def direction_list
    @directions = [[1, 1], [1, -1], [1, 0], [0, 1]].freeze
  end

end