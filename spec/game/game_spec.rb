# frozen-string-literal: true

require_relative './../../lib/game'
require_relative './../../lib/rules/move_validation'
require_relative './../../lib/board'
require_relative './../../lib/translator'
require_relative './../../lib/display/game_output'
require_relative './../../lib/pieces/pawn'
require_relative './../../lib/pieces/king'
require_relative './../../lib/pieces/queen'
require_relative './../../lib/pieces/bishop'
require_relative './../../lib/pieces/knight'
require_relative './../../lib/pieces/rook'
require_relative './../../lib/pieces/general'


describe Game do

  subject(:game) { described_class.new(game_components) }
  let(:array) {  Array.new(8) { Array.new(8) } }
  let(:board) { instance_double(Board, board: array) }
  let(:validator) { instance_double(MoveValidator) }
  let(:output) { instance_double(GameOutput) }
  let(:translator) { Translator.new }
  let(:game_components) {
    {
      board: board, translator: translator, validator: validator, output: output
    }
  }

  describe '#obtain_validate_input' do
    
    before do
      allow(game).to receive(:gets).and_return('')
      allow(game).to receive(:valid_input?).and_return(false, true)
    end
    
    context 'when selecting a piece with invalid then valid input' do

      it 'shows the input prompt twice, the invalid/error message once' do
        expect(output).to receive(:text_message).with(:invalid_notation)
        expect(output).to receive(:text_message).with(:selection_prompt, anything).twice
        game.obtain_validate_input
      end
    end

    context 'when specifying a destination for a piece' do
      it 'uses the destination prompt' do
        expect(output).to receive(:text_message).with(:invalid_notation)
        expect(output).to receive(:text_message).with(:destination_prompt, anything).twice
        game.obtain_validate_input(true)
      end
    end
    
  end

  describe '#selection_processes' do
    before do
      allow(validator).to receive(:take_board_snapshot)
      allow(output).to receive(:take_snapshot)
      allow(output).to receive(:display_game_state)
      allow(game).to receive(:make_selection)
    end
    it 'updates validator and output with the new board' do
      expect(output).to receive(:take_snapshot).with(board.board)
      expect(validator).to receive(:take_board_snapshot)
      game.selection_processes
    end
  end

  describe '#make_selection' do
    let(:white_pawn) { instance_double(Pawn) }

    before { allow(game).to receive(:process_input) }
    
    context 'when an invalid (empty) then valid (friendly) square is specified' do
      before do
        allow(game).to receive(:obtain_validate_input)
        allow(game).to receive(:label_piece).and_return(:empty, [:friendly, white_pawn])
      end
      it 'displays an empty selection message, then returns the selected piece' do
        expect(output).to receive(:text_message).with(:empty_selection)
        expect(game).to receive(:process_input).twice
        game.make_selection
      end
    end

    context 'when quit is entered' do
      before { allow(game).to receive(:obtain_validate_input).and_return('quit') }
      it 'calls #quit_game and sets @end_game to true before returning' do
        expect(game).to receive(:quit_game)
        expect(game).not_to receive(:process_input)
        game.make_selection
      end
    end

    context 'when another command (here \'commands\') is entered' do
      before do
        allow(game).to receive(:obtain_validate_input).and_return('commands', '')
        allow(game).to receive(:label_piece).and_return([])
      end

      it 'calls #handle_command once and jumps to the next iteration' do
        expect(game).to receive(:handle_commands)
        expect(game).to receive(:label_piece).once
        game.make_selection
      end
    end
  end

  describe '#make_move' do
    before do
      allow(output).to receive(:text_message)
      allow(board).to receive(:update_board)
      allow(board).to receive(:revert_board)
    end

    context 'when the move is invalid' do
      it 'prints \'check\' message if the player is in check' do
        allow(game).to receive(:validate_move).and_return([:check, ''], [true, ''])
        expect(output).to receive(:text_message).with(:check_msg, anything)
        expect(board).to receive(:revert_board)
        game.make_move('')
      end

      it 'prints \'ally\' message if the destination has an allied piece' do
        allow(game).to receive(:validate_move).and_return([:ally, ''], [true, ''])
        expect(output).to receive(:text_message).with(:ally_occupied)
        game.make_move('')
      end

      it 'prints invalid \'castle\' message if the castling was invalid' do
        allow(game).to receive(:validate_move).and_return([:no_castle, ''], [true, ''])
        expect(output).to receive(:text_message).with(:invalid_castle)
        game.make_move('')
      end

      it 'prints invalid \'en passant\' message if an attempt at en passant ended in failure' do
        allow(game).to receive(:validate_move).and_return([:no_en_passant, ''], [true, ''])
        expect(output).to receive(:text_message).with(:invalid_en_passant)
        game.make_move('')
      end

      it 'prints \'not in moveset\' message if the destination is not a valid move' do
        allow(game).to receive(:validate_move).and_return([:not_in_moveset, ''], [true, ''])
        expect(output).to receive(:text_message).with(:invalid_destination)
        game.make_move('')
      end
    end
  end

  describe '#validate_move' do
    context 'when \'quit\' is enterd' do

      before { allow(validator).to receive(:king_in_check?) }

      it 'calls quit_game and returns' do
        allow(game).to receive(:obtain_destination_square).and_return('quit')
        expect(game).to receive(:quit_game)
        expect(game).not_to receive(:obtain_meta_info)
        game.validate_move('')
      end

      it 'sets @end_game to true' do
        allow(game).to receive(:obtain_destination_square).and_return('quit')
        game.validate_move('')
        end_game = game.instance_variable_get(:@end_game)
        expect(end_game).to be 'quit'
      end
    end

    context 'when the current player\'s king is in check' do
      it 'returns :check' do
        allow(game).to receive(:obtain_destination_square)
        expect(validator).to receive(:king_in_check?).and_return(true)
        expect(game).not_to receive(:obtain_meta_info)
        game.validate_move('')
      end
    end

    context 'when input is valid and the player\'s king is not in check' do

      before do
        allow(game).to receive(:obtain_destination_square).and_return('destination')
        allow(validator).to receive(:king_in_check?).and_return(false)
        allow(game).to receive(:check_after_move?)
        allow(game).to receive(:move_is_valid?).and_return(true)
        allow(game).to receive(:obtain_meta_info)
      end

      it 'gets meta info (destination label and movement category) and validates the move' do
        expect(game).to receive(:obtain_meta_info)
        expect(game).to receive(:move_is_valid?)
        game.validate_move('')
      end

      it 'returns an array containing true and the destination' do
        piece = ''
        result = game.validate_move(piece)
        expect(result).to eq [true, 'destination']
      end
    end

  end

  
  describe '#move_is_valid?' do

    context 'when called with :normal category tag' do
      it 'calls #validate_normal_move?' do
        # allow(game).to receive(:validate_normal_move?)
        piece = ''
        destination = [0, 0]
        meta_info = { contents: :empty, category: :normal }
        expect(game).to receive(:validate_normal_move?).with(piece, destination, meta_info)
        game.move_is_valid?(piece, destination, meta_info)
      end
    end

    context 'when called with :castling category tag' do
      it 'calls #validate_castling_move' do
        piece = ''
        destination = [0, 0]
        meta_info = { contents: :empty, category: :castling }
        expect(game).to receive(:validate_castling_move).with(piece, destination, meta_info)
        game.move_is_valid?(piece, destination, meta_info)
      end
    end
  end

  describe '#validate_castling_move' do
    let(:piece) { instance_double(Pawn) }
    let(:destination) { [0, 0] }
    context 'when called' do
      it 'returns false if castling is invalid' do
        allow(validator).to receive(:castling).and_return(false)
        result = game.validate_castling_move(piece, destination)
        expect(result).to be false
      end

      it 'calls Board#update_castle and returns true for a valid castle' do
        allow(validator).to receive(:castling).and_return([])
        expect(board).to receive(:update_castle)
        result = game.validate_castling_move(piece, destination)
        expect(result).to be true
      end
    end
  end

  describe '#castling_on_starting_rank?' do
    let(:black_king) { King.new(:black, [0, 0]) }
    let(:white_king) { King.new(:white, [1, 0]) }
    let(:not_a_king) { Piece.new(:some_colour, [100, 100]) }

    context 'when the king is on the wrong rank' do
      it 'returns false' do
        piece = white_king
        destination = [0, 0]
        result = game.castling_on_starting_rank?(piece, destination)
        expect(result).to be false
      end
    end

    context 'when the king is on the right rank, but the destination is invalid' do
      it 'returns false' do
        piece = black_king
        destination = [6, 0]
        result = game.castling_on_starting_rank?(piece, destination)
        expect(result).to be false
      end
    end

    context 'when the the piece passed is not a king' do
      it 'returns false' do
        piece = not_a_king
        destination = [0, 0]
        result = game.castling_on_starting_rank?(piece, destination)
        expect(result).to be false
      end
    end

    context 'when a valid king and destination is provided' do
      it 'returns false' do
        piece = black_king
        destination = [0, 3]
        result = game.castling_on_starting_rank?(piece, destination)
        expect(result).to be true
      end
    end
  end

  describe '#validate_normal_move?' do
    let(:black_rook) { Rook.new(:black, [0, 0]) }
    let(:white_pawn) { Pawn.new(:white, [6, 3]) }
    context 'when the destination is not an available move' do
      it 'returns :not_in_moveset' do
        piece = black_rook
        allow(piece).to receive(:available_moves).and_return [[1, 0], [0, 1]]

        invalid_destination = [3, 3]
        result = game.validate_normal_move?(piece, invalid_destination, {})
        expect(result).to eq :not_in_moveset
      end
    end

    context 'when the destination square has a friendly piece' do
      it 'returns false' do
        piece = black_rook
        allow(piece).to receive(:available_moves).and_return [[1, 0], [2, 0], [3, 0], [4, 0]]

        valid_destination = [3, 0]
        meta_info = { contents: :friendly }
        result = game.validate_normal_move?(piece, valid_destination, meta_info)
        expect(result).to be false
      end
    end

    context 'when the piece is a pawn and the moves are valid' do
      it 'calls MoveValidator#en_passant?' do
        piece = white_pawn
        allow(piece).to receive(:available_moves).and_return [[3, 0]]
        valid_destination = [3, 0]
        meta_info = { contents: :friendly }
        expect(validator).to receive(:en_passant?)
        game.validate_normal_move?(piece, valid_destination, meta_info)
      end
    end

    context 'when a pawn is making an en_passant capture' do
      it 'returns true' do
        piece = white_pawn
        allow(piece).to receive(:available_moves).and_return [[3, 0]]

        valid_destination = [3, 0]
        meta_info = { contents: :empty }
        expect(validator).to receive(:en_passant?)
        result = game.validate_normal_move?(piece, valid_destination, meta_info)
        expect(result).to be true
      end
    end
  end

  describe '#promotion_check' do
    let(:white_pawn) { Pawn.new(:white, [0, 4]) }
    let(:black_pawn) { Pawn.new(:black, [6, 2]) }
    let(:not_a_pawn) { King.new(:white, [0, 5]) }

    before { allow(game).to receive(:new_piece_input).and_return 'q' }

    context 'when a pawn is not at the end of the board' do
      it 'returns nil' do
        piece = black_pawn
        result = game.promotion_check(piece)
        expect(result).to be_nil
      end
    end

    context 'when a pawn is not given as an argument' do
      it 'returns nil' do
        piece = not_a_pawn
        result = game.promotion_check(piece)
        expect(result).to be_nil
      end
    end

    context 'when a pawn has reached the end of the board' do
      it 'calls Board#promote and displays a message' do
        game.instance_variable_set(:@active_player, :white)
        expect(board).to receive(:promote)
        expect(output).to receive(:text_message)
        piece = white_pawn
        game.promotion_check(piece)
      end
    end
  end

  describe '#new_piece_input' do

    context 'when invalid input then valid input is given' do
      it 'displays \'invalid promotion\' message then returns input' do
        allow(game).to receive(:gets).and_return('nah mate', 'queen')
        expect(output).to receive(:text_message).with(:promotion_prompt).once
        expect(output).to receive(:text_message).with(:invalid_promotion).once
        result = game.new_piece_input
        expect(result).to eq 'q'
      end
    end
  end

  describe '#end_game?' do
    let(:players) { %i[white black] }

    before { game.instance_variable_set(:@players, players) }

    context 'when there is no checkmate or stalemate' do
      it 'returns false' do
        allow(validator).to receive(:end_game_conditions?).and_return(false, false)
        result = game.end_game?
        expect(result).to be false
      end
    end

    context 'when there a stalemate' do
      it 'returns true and sets @end_game to :stalemate' do
        allow(validator).to receive(:end_game_conditions?).and_return(false, :stalemate)
        result = game.end_game?
        type = game.instance_variable_get(:@end_game)
        expect(result).to be true
        expect(type).to eq :stalemate
      end
    end

    context 'when there is a checkmate' do
      it 'returns true, sets @end_game to :mated and @winner is set accordingly' do
        allow(validator).to receive(:end_game_conditions?).and_return(:mated, false)
        result = game.end_game?
        type = game.instance_variable_get(:@end_game)
        winner = game.instance_variable_get(:@winner)
        expect(result).to be true
        expect(type).to eq :mated
        expect(winner).to eq :black
      end
    end
  end

  describe '#serialise' do
    let(:fname) { 'My_save' }

    context 'when called' do
      before do
        allow(game).to receive(:obtain_file_name).and_return(fname)
        allow(File).to receive(:open)
        allow(output).to receive(:theme)
        allow(output).to receive(:board_history_stack)
      end
      it 'creates a file' do
        expect(File).to receive(:open).with("saves/#{fname}", 'w')
        game.serialise
      end
    end
  end

  describe '#obtain_file_name' do
    let(:fname) { 'my_save' }
    before do
      allow(output).to receive(:text_message)
    end

    context 'when the input is less than two characters and then valid' do
      it 'calls File#exist? once and returns the file name' do
        allow(game).to receive(:gets).and_return('a', fname)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).once
        result = game.obtain_file_name
        expect(result).to eq fname
      end
    end

    context 'when the file exists, and the user requests an overwrite' do
      it 'it displays the \'overwrite\' message, then breaks loop' do
        allow(game).to receive(:gets).and_return(fname, 'y')
        allow(File).to receive(:exist?).and_return(true)
        expect(output).to receive(:text_message).with(:overwrite_prompt).once
        game.obtain_file_name
      end
    end

    context 'when the user declines to overwrite a save' do
      it 'loops until a valid file name or overwrite request is given' do
        allow(game).to receive(:gets).and_return(fname, 'n', fname, 'n', fname, 'y')
        allow(File).to receive(:exist?).and_return(true, true, false)
        expect(output).to receive(:text_message).with(:overwrite_prompt).twice
        game.obtain_file_name
      end
    end
  end

  describe '#valid_input?' do
    let(:valid_notation) { 'a5' }
    let(:invalid_notation) { 'aaa4' }
    let(:command) { 'save' }

    context 'when a command is entered' do
      it 'returns true' do
        input = command
        result = game.valid_input?(command)
        expect(result).to be true
      end
    end

    context 'when notation is used' do
      it 'calls Translator#valid_notion?' do
        input = 'random'
        expect(translator).to receive(:valid_notation?)
        game.valid_input?(input)
      end
    end
  end

end