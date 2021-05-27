# frozen-string-literal: true


# Translates the chess notation to be compatible with the program
class Translator

  attr_reader :input

  # For when the different ways to move are sorted out
  # def translate
  #   return 'input_error' unless valid_notation?

  #   quick = quick_move?
  #   [quick, translate_location]
  # end

  # Checks if the regexp is matched
  def valid_notation?(notation)
    return false if notation.length > 3

    notation.match(/[QNBPKR]?[a-h][1-8]/).is_a? MatchData
  end

  def translate_location(loc)
    row = decode(loc[-1])
    col = decode(loc[-2])
    [row, col]
  end

  def decode(digit)
    digit.to_i.zero? ? (digit.ord - 97) : (digit.to_i - 1)
  end

end