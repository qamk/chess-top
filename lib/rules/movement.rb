# frozen-string-literal: true

# Controls the movement for the chess pieces
class Movement

  attr_reader :active_piece

  def focus_on(active_piece)
    @active_piece = active_piece
  end

  def populate_available_moves
    
  end

  def perform_quick_move(piece, coords)
    change_in_position = calculate_component_difference([piece.location, coords].transpose)
    scaler_list = calculate_scalers(piece.directions, change_in_position)
    verify_move(scaler_list)
  end

  def verify_move(scalers)
    scalers.uniq.count == 1
  end

  def calculate_scalers(directions, delta_position)
    scaler = proc { |a, b| a / b }
    directions.map do |direction|
      component_match = [delta_position, direction].transpose
      component_match.map { |component| scaler.call(component) }
    end
  end

  def calculate_component_difference(component_vectors)
    difference = proc { |a, b| b - a }
    difference = component_vectors.map { |component| difference.call(component) }
  end

end