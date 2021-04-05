# frozen-string-literal: true

# Controls the movement for the chess pieces
class Movement

  attr_reader :active_piece

  # Instead of passing "piece", active piece will be used instead
  # Sort out 0 division stuff
  def focus_on(active_piece)
    @active_piece = active_piece.clone
  end

  # Each piece needs a method for updating @available_moves, @location, @captured
  def calculate_move_vectors(directions, location)
    sum = proc { |a, b| a + b }
    directions.map do |direction|
      component_match = [direction, location].transpose
      component_match.map { |component| sum.call(component) }
    end
  end

  def find_all_legal_moves(num_jumps = 7, location = active_piece.location, p_directions = active_piece.directions)
    unfilterd_moves = []
    directions = p_directions.negate
    (1..num_jumps).each do |scaler|
      scaled_directions = multiply_by_scaler(directions, scaler)
      prospective_moves = calculate_move_vectors(scaled_directions, location)
      # print "\e[0m\t\e[32mCoef: #{scaler}\n\t\e[33mLocation: #{location}\n\e[34mScaled_directions: #{scaled_directions}\n\e[36mProspective_moves: #{prospective_moves}\n"
      prospective_moves.each { |p_move| unfilterd_moves << p_move }
    end
    unfilterd_moves.select { |a, b| a.between?(0, 7) && b.between?(0, 7) }
  end

  def normal_move
    return find_all_legal_moves unless %w[Pawn Knight King].include? active_piece.class.to_s

    find_all_legal_moves(1)
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

  def perform_quick_move(coords)
    change_in_position = calculate_component_difference([active_piece.location, coords].transpose) # handle in other method
    scaler_list = calculate_scalers(active_piece.directions, change_in_position)
    verify_quick_move?(scaler_list)
  end

  def verify_quick_move?(scalers)
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