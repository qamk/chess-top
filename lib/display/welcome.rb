# frozen-string-literal: true

module Welcome

  def welcome_msg
    puts %(
      Welcome to v1.0. This program is simply a game of \e[1mchess\e[0m.
      I hope you enjoy this program!
      Below is some information about chess.
      Chess is a board game where you have two players Black & White.
      Each player has the following pieces:
        1 \e[31mKing\e[0m
        1 Queen
        2 Bishops
        2 Knights
        2 Rooks
        8 Pawns
      The ultimate goal is to get the opponent in King in a "\e[32mCheckmate\e[0m".
      This is where a King is unable to make any moves without being taken (i.e. it has been mated).
      A King must be in \e[34mcheck\e[0m before (or at the same time that) it is mated.
      Each piece has a set of directions in which it can move and number of squares it can cross per move.
      This will become clearer when you play.
      In order to \e[34mcapture\e[0m a piece, you must move your piece on top of an opponent piece.
      A King is in \e[36mcheck\e[0m when it is able to be captured by an opponent piece in the next move.
      When in your King is in check \e[33mcheck\e[0m your next move must get you out of check.
      As stated above, when this is not possible you are in checkmate and you lose.
      Finally there is also stalemate, wherein a King is not in check and has no safe moves available.
      Really, just play or read online for more information. There are things I left out such as
        Castling
        En Passant
      Which I may expand on in future versions.
    ) 
  end

  def game_menu_msg
    puts %(
      Please select one of the following options by typing the number or 'q'/'quit' to quit:
        1\) New 2-player Game
        2\) Load game
    )
  end

  def game_menu_error_msg
    puts 'Please ensure you have selected a valid option'
  end

end
