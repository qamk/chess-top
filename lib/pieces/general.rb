# frozen-string-literal: true

# Contains attributes and methods mutual to each piece
class Piece
  def initialize(colour)
    @symbol = ''
    @value = 1.0
    @directions = []
    @available_moves = []
    @captured = false
    @colour = colour
  end
end
