# frozen-string-literal: true

# Contains different text messages for the game
module TextOutput

  COMMANDS = [['198','commands --> bring up game instructions'],
              ['27','save --> save the game'],
              ['226', 'quit --> exit the game']]

  def hostile_selection
    puts "#{"Invalid selection".red}. Please select one of your pieces, not the other player's"
  end

  def empty_selection
    puts "#{"Invalid selection".red}. That square is empty, please select one of your piece's squares."
  end

  def command_list_msg
    puts "The commands currently are: "
    COMMANDS.each { |c| print "\t\e[38;5;#{c[0]}m#{c[1]}\e[0m\n" }
    puts "Press enter to continue..."
    gets.chomp
  end

  def selection_promt(colour)
    puts "#{colour.upcase.bold} to select. Please enter the location of the piece you want to move (alternatively enter a command):"
  end

  def destination_prompt(colour)
    puts "#{colour.upcase.bold} to move. Please enter the location you want to move this piece to (alternatively enter a command):"
  end

  def invalid_destination
    puts "#{"Invalid destination".red}. Please ensure your piece can move there."
  end

  def invalid_notation
    puts "#{"Invalid notation".yellow}. Make sure to use a-h and 1-8, e.g. a7."
  end
  
  def invalid_castle
    puts "#{"Invalid castle".magenta}."
  end
  
  def invalid_en_passant
    puts "Conditions #{"not".italics} met for #{"en passant".magenta}."
  end
  
  def invalid_promotion
    puts "#{"Invalid promotion".yellow}. Please ensure you enter either b, n, r or q. Alternatively enter the new piece name."
  end

  def ally_occupied
    puts "#{"Invalid destination"}. Your piece already occupies that square."
  end


  def checkmate_msg(winner)
    loser = winner == "Black" ? "White" : "Black" 
    puts "#{"Checkmate".green} on #{loser} king! Congrats to #{winner.upcase.bold}"
  end

  def stalemate_msg
    puts "#{"Stalemate".yellow}. No legal moves can be made and King is not in check."
  end

  def check_msg(colour)
    puts "Cannot make that move because the #{colour} #{"king is in check.".bold.yellow}"
    puts "Please make a move that will get the king out of check."
  end

  def promotion_prompt
    puts "Your pawn can now be promoted. You can promote to:\n\t Bishop (b), Knight (n), Rook (r), Queen (q)."
    puts "To promote, just enter the name of the new piece or the corresponding letter code (b, n, r or q)."
  end


  def promotion_success(new_piece)
    puts "Pawn promoted to #{new_piece.blue}."
  end

  def quit_msg
    puts "Thank you for playing. Quitting the game. Press enter to continue."
    gets
  end


  # Colours

  def red
    "\e[31m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def yellow
    "\e[33m#{self}\e[0m"
  end

  def green
    "\e[32m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[0m"
  end

  def italics
    "\e[3m#{self}\e[0m"
  end


end