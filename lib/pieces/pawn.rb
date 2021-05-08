# frozen-string-literal: true

require_relative 'general'

# Characteristics of the Bishop class
class Pawn < Piece
  def initialize(colour, location)
    super(colour, location)
    @value = 3.5
  end

  def direction_list
    @directions = valid_player_directions.freeze
  end

  def valid_player_directions
    if colour == :white
      [[1, 0], [2, 0], [1, 1], [1, -1]]
    else
      [[-1, 0], [-2, 0], [-1, -1], [-1, 1]]
    end
  end

end