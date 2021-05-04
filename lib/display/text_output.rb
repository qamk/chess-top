# frozen-string-literal: true

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
    puts "That destination is #{"invalid".red}. Please ensure your piece can move there.
  end

  def invalid_notation
    puts "#{"Invalid notation".magenta}. Make sure to use a-h and 1-8, e.g. a7."
  end

  def checkmate_msg(winner)
    loser = winner == "Black" ? "White" : "Black" 
    puts "#{"Checkmate".green} on #{loser} king! Congrats to #{winner.upcase.bold}"
  end

  def stalemate_msg
    puts "#{"Stalemate".yellow}. No legal moves can be made and King is not in check."
  end

  def check_msg(colour)
    puts "Cannot make that move because the #{colour.bold} king is in check."
    puts "Please make a move that will #{"get the king out of check".italics}."
  end


  # Colours

  def red
    "\e[31m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
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