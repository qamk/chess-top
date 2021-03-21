# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Pawn < Piece
  def initialize(colour)
    super(colour)
    @value = 3.5
    freeze
  end

  def direction_list
    @directions = [0, 1].freeze
  end

end