# frozen-string-literal: true


# Translates the chess notation to be compatible with the program
class Translator

  attr_reader :input

  def focus_on(input)
    @inptut = input
  end

  # For when the different ways to move are sorted out
  # def translate
  #   return 'input_error' unless valid_notation?

  #   quick = quick_move?
  #   [quick, translate_location]
  # end

  # Checks if the regexp is matched
  def valid_notation?
    input.match(/[QNBPKR][a-h][1-8]/).is_a? MatchData
  end

  def translate_location(loc = input)
    row = loc[-1].decode
    col = loc[-2].decode
    [row, col]
  end

  def decode
    is_a?(Integer) ? (to_i - 1) : (ord - 97)
  end

end