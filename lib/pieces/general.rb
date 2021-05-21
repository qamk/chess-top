# frozen-string-literal: true

# Contains attributes and methods mutual to each piece
class Piece
  attr_reader :colour, :directions, :available_moves, :location, :symbol
  def initialize(colour, location)
    @symbol = ''
    @value = 1.0
    @directions = []
    @available_moves = []
    @location = location
    @captured = false
    @colour = colour
  end

  # replace clear with something non-destructive
  def update_available_moves(moves)
    @available_moves.clear
    @available_moves.concat(moves)
  end

  def update_location(new_location)
    @location.clear
    @location.concat(new_location)
  end

  # def captured?
  #   @captured = true
  # end
end
