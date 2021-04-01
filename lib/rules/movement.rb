# frozen-string-literal: true

# Controls the movement for the chess pieces
class Movement

  attr_reader :active_piece

  # Instead of passing "piece", active piece will be used instead

  def focus_on(active_piece)
    @active_piece = active_piece
  end

  # Each piece needs a method for updating @available_moves, @location, @captured
  def populate_available_moves(directions, location)
    sum = proc { |a, b| a + b }
    directions.map do |direction|
      component_match = [direction, location].transpose
      component_match.map { |component| sum.call(component) }
    end
  end

  def moves_to_end(piece_directions, location)
    unfilterd_moves = []
    directions = piece_directions.clone.negate
    (1..7).each do |scaler|
      scaled_directions = multiply_by_scaler(directions, scaler)
      prospective_moves = populate_available_moves(scaled_directions, location)
      print "\e[0m\t\e[32mCoef: #{scaler}\n\t\e[33mLocation: #{location}\n\e[34mScaled_directions: #{scaled_directions}\n\e[36mProspective_moves: #{prospective_moves}\n"
      prospective_moves.each { |p_move| unfilterd_moves << p_move }
    end
    unfilterd_moves.select { |a, b| a.between?(0, 7) && b.between?(0, 7) }
  end

  def multiply_by_scaler(array, scaler)
    return array if scaler == 1

    array.map { |a, b| [a * scaler, b * scaler] }
  end

  # Appends the negated directions so a piece has a complete list of directions
  def negate
    additive_inverse = proc { |a, b| [a * -1, b * -1] }
    inverse = map { |coord| additive_inverse.call(coord) }
    inverse.each { |inv| push(inv) }
  end

  def perform_quick_move(piece, coords)
    change_in_position = calculate_component_difference([piece.location, coords].transpose) # handle in other method
    scaler_list = calculate_scalers(piece.directions, change_in_position)
    verify_quick_move(scaler_list)
  end

  def verify_quick_move(scalers)
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