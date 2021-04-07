# frozen-string-literal: true

require_relative '../board'
require_relative ''

# Handles input and general game functions
class Game
  def initialize(game_components)
    @game_board = game_components[:board]
    @game_translator = game_components[:translator]
    @game_spectator = game_components[:spectator]
  end

  
end