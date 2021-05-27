# frozen-string-literal: true

require_relative 'text_output'

# Handles displaying the board amongst other elements
class GameOutput
  include TextOutput
  attr_reader :board, :theme, :board_history_stack, :current_piece

  # An empty square is 4 spaces ("    ")

  def initialize(board, theme = :classic)
    @board = board.dup
    @theme = change_theme(theme)
    @board_history_stack = [board]
    @current_piece = nil
  end

  # Last piece that was selected or moved
  def obtain_current_piece(current_piece = nil)
    @current_piece = current_piece
  end

  def text_message(message, arg = nil, board = true)
    display_game_state if board
    arg.nil? ? send(message) : send(message, arg)
  end

  def display_game_state
    system('clear')
    print_board
  end

  def clear_current_piece
    @current_piece = nil
  end

  def print_board(p_board = board)
    print_header
    p_board.each_with_index do |row, r_index|
      print r_index + 1
      print_row(row, r_index)
      puts
    end
  end

  def print_header
    puts " \ta \tb \tc \td \te \tf \tg \th "
  end

  def print_row(row, r_index)
    row.each_with_index do |piece, f_index|
      colour = { white: 97, black: 30 }
      colour_index = (r_index + f_index) % 2
      theme_colour = theme[colour_index]
      move_to = in_current_piece(r_index, f_index) unless current_piece.nil?
      piece_colour = colour[piece.colour] unless piece.nil?
      print_square(piece, theme_colour, move_to, piece_colour)
    end
  end

  def in_current_piece(rank, file)
    current_piece.available_moves.include? [rank, file]
  end

  def print_square(piece, bg_colour, move_to, piece_colour)
    if piece.nil? && move_to
      print "\e[#{bg_colour};#{theme[-1]}m    \u25CF    \e[0m"
    elsif piece && move_to
      print "\e[#{theme[-2]};#{piece_colour}m    #{piece.symbol}    \e[0m"
    elsif piece.nil?
      print "\e[#{bg_colour}m         \e[0m"
    else
      print "\e[#{bg_colour};#{piece_colour}m    #{piece.symbol}    \e[0m"
    end
  end

  def change_theme(theme_key)
    # [dark_bg, light_bg, highlight_bg, highlight_circle]
    {
      classic: ['100', '48;5;57', '48;5;208', '38;5;208']
      # mint: [#mint_bg, dim_mint_bg, blue_bg, blue_circle]
    }[theme_key]
  end

  def take_snapshot(current_board)
    @board_history_stack.unshift(board)
    @board = current_board.dup
  end

  def import_theme(theme)
    @theme = theme
  end

  def import_history(history)
    @board_history_stack = history
  end

  def view_past_boards;end

end