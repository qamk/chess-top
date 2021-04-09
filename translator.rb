# frozen-string-literal: true


# Translates the chess notation to be compatible with the program
class Translator

  attr_reader :input

  def translate(input)
    @input = input
    return 'input_error' unless valid_notation?

    quick = quick_move?
    [quick, translate_location]
  end

  # Quick move or not
  def quick_move?
    input[0] == '#'
  end

  # Checks if the regexp is matched
  def valid_notation?
    input =~ /#?[QNBPKR][a-h][1-8]/
  end

  def translate_location
    row = input[-1].decode
    col = input[-2].decode
    [row, col]
  end

  def decode
    is_a?(Integer) ? (to_i - 1) : (ord - 97)
  end

end