# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Bishop < Piece
  def initialize(colour)
    super(colour)
    @value = 3.5
    freeze
  end

  def direction_list
    @directions = [[1, 1], [-1, 1]].freeze
  end

end