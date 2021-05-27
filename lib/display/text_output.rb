# frozen-string-literal: true

require_relative 'colours'

# Contains different text messages for the game
module TextOutput

  COMMANDS = [
    ['198', 'commands --> bring up game instructions'],
    ['27', 'save --> save the game'],
    ['226', 'quit --> exit the game']
  ].freeze

  def hostile_selection
    puts "#{'Invalid selection'.red}. Please select one of your pieces, not the other player's"
  end

  def empty_selection
    puts "#{'Invalid selection'.red}. That square\'s contents cannot move, please select a moveable piece."
  end

  def command_list_msg
    puts 'The commands currently are: '
    COMMANDS.each { |c| print "\t\e[38;5;#{c[0]}m#{c[1]}\e[0m\n" }
    puts 'Press enter to continue...'
    gets.chomp
  end

  def selection_prompt(colour)
    colour = colour.to_s.bold
    puts "#{colour} to select. Please enter the location of the piece you want to move (alternatively enter a command): "
    print "type 'commands' to see the command list".yellow226.dim
    puts
  end

  def destination_prompt(colour)
    colour = colour.to_s.bold
    puts "#{colour} to move. Please enter the location you want to move this piece to (alternatively enter a command): "
    print "type 'commands' to see the command list".yellow226.dim
    puts
  end

  def invalid_destination
    puts "#{'Invalid destination'.red}. Please ensure your piece can move there."
  end

  def invalid_notation
    puts "#{'Invalid notation'.yellow}. Make sure to use a-h and 1-8, e.g. a7."
  end

  def invalid_castle
    puts "#{'Invalid castle'.magenta}."
  end

  def invalid_en_passant
    puts "Conditions #{'not'.italics} met for #{'en passant'.magenta}."
  end

  def invalid_promotion
    puts "#{'Invalid promotion'.yellow}. Please ensure you enter either b, n, r or q. Alternatively enter the new piece name."
  end

  def ally_occupied
    puts "#{'Invalid destination'.cyan}. Your piece already occupies that square."
  end

  def file_name_prompt
    puts "Please enter a #{'file name'.blue} to save your game. At least 2 characters (e.g. initials). To return to the game type 'q' or 'quit':"
  end

  def overwrite_prompt
    puts "#{'File aready exists'.yellow}. Would you like to #{"overwrite"} this file? (y/n)"
  end

  def checkmate_msg(winner)
    loser = winner == 'Black' ? 'White' : 'Black'
    puts "#{'Checkmate'.green} on #{loser} king! Congrats to #{winner.upcase.bold}"
  end

  def stalemate_msg
    puts "#{'Stalemate'.yellow}. No legal moves can be made and King is not in check."
  end

  def check_msg(colour)
    colour = colour.to_s.yellow.bold
    puts "#{colour} #{'king is in check.'.bold.yellow}"
    puts 'Please make a move that will get the king out of check.'
  end

  def promotion_prompt
    puts "Your pawn can now be promoted. You can promote to:\n\t Bishop (b), Knight (n), Rook (r), Queen (q)."
    puts 'To promote, just enter the name of the new piece or the corresponding letter code (b, n, r or q).'
  end

  def promotion_success(new_piece)
    puts "Pawn promoted to #{new_piece.blue}."
  end

  def quit_msg
    puts 'Thank you for playing. Quitting the game. Press enter.'
    gets
  end
end
