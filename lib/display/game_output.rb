# frozen-string-literal: true

require_relative 'text_output'

# Handles displaying the board amongst other elements
class GameOutput
  include TextOutput
  attr_reader :board, :theme, :board_history_stack, :last_piece

  # An empty square is 4 spaces ("    ")

  def initialize(board, theme = :classic)
    @board = board
    @theme = change_theme(theme)
    @board_history_stack = [board]
    @last_piece = nil
  end

  # Last piece that was selected or moved
  def obtain_last_piece(last_piece = nil)
    @last_piece = last_piece
  end

  def text_message(message, board = true, arg = nil)
    display_game_state if board
    args.nil? ? send(message) : send(message, arg)
  end

  def display_game_state
    take_snapshot
    flip if last_piece.colour == :black
    print_board
    FILE.each { |file| print "  #{file}  " }
  end

  def print_board(p_board = board)
    p_board.each_with_index do |row, r_index|
      print " #{8 - r_index} "
      print_row(row, r_index)
    end
  end

  def print_row(row, r_index)
    row.each_with_index do |piece, f_index|
      colour_index = f_index % 2
      theme_colour = theme[colour_index]
      move_to = in_last_piece(r_index, f_index) unless last_piece.nil?
      print f_index
      piece_colour = piece.colour == :white ? 97 : 30
      print_square(piece, theme_colour, move_to, piece_colour)
      puts
    end
  end

  def in_last_piece(rank, file)
    last_piece.include? [rank, file]
  end

  def print_square(piece, bg_colour, move_to, piece_colour)
    if piece.nil? && move_to
      print "\e[#{bg_colour}; #{theme[-1]}m    \e[0m"
    elsif piece && move_to
      print "\e[#{theme[-2]};#{piece_colour}m    #{piece.symbol}\e[0m"
    elsif piece.nil?
      print "\e[#{bg_colour}m    \e[0m"
    else
      print "\e[#{bg_colour};#{piece_colour}m    #{piece.symbol}\e[0m"
    end
  end

  def change_theme(theme_key)
    themes = {
      # classic: [black_bg, grey_bg, orange_bg, orange_circle]
      # mint: [#mint_bg, dim_mint_bg, blue_bg, blue_circle]
    }
  end

  def flip
    @board = board.reverse
  end

  def take_snapshot(current_board)
    @board_history_stack.unshift(board)
    @board = current_board
  end

  def view_past_boards

  end

end