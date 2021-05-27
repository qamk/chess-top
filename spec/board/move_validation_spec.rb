# frozen-string-literal: true

require_relative './../../lib/rules/move_validation'
require_relative './../../lib/rules/movement'
require_relative './../../lib/spectator'
require_relative './../../lib/pieces/knight'
require_relative './../../lib/pieces/bishop'
require_relative './../../lib/pieces/rook'
require_relative './../../lib/pieces/queen'
require_relative './../../lib/pieces/king'
require_relative './../../lib/pieces/pawn'

describe MoveValidator do
  
  subject(:validator) { described_class.new(board, spectator, mover) }
  let(:spectator) { Spectator.new(mover) }
  let(:mover) { Movement.new }
  let(:board) { [] }
    
  describe '#find_king' do
    
    let(:black_king) { King.new(:black, [0, 2]) }
    let(:white_king) { King.new(:white, [7, 6]) }
    let(:both_kings_board) {
      [
        [nil, nil, black_king, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, white_king, nil]
      ]
    }
    
    context 'when no colour is specified' do
      before { validator.spectator.instance_variable_set(:@board, both_kings_board) }
      it 'returns a list of each king' do
        result = validator.find_king
        result_length = result.length
        result_colours = result.map(&:colour)
        expect(result_length).to eq 2
        expect(result).to all(be_a(King))
        expect(result_colours).to match_array(%i[white black])
      end

    end

    context 'when a colour is specified' do
      before { validator.spectator.instance_variable_set(:@board, both_kings_board) }
      it 'returns a list containing one king' do
        result_white = validator.find_king(:white)
        result_black = validator.find_king(:black)
        expect(result_black).to eq [black_king]
        expect(result_white).to eq [white_king]
      end

    end

  end

  describe '#identify_target_locking_candidates' do
    let(:black_knight) { Knight.new(:black, [3, 4]) }
    let(:black_rook) { Rook.new(:black, [5, 2]) }
    let(:black_queen) { Queen.new(:black, [5, 1]) }
    let(:white_rook) { Rook.new(:white, [5, 6]) }
    let(:white_queen) { Queen.new(:white, [5, 5]) }
    let(:white_king) { King.new(:white, [0, 0]) }
    let(:target_locking_board) {
      [
        [white_king, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, black_knight, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, black_queen, black_rook, nil, nil, white_queen, white_rook, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }
    before { validator.spectator.instance_variable_set(:@board, target_locking_board) }
    context 'when a target is in direction of a piece' do

      it 'returns a list of pieces that \'look\' at the target' do
        target = white_queen
        colour = white_queen.colour
        result = validator.identify_target_locking_candidates(target, colour)
        expect(result).to match_array([black_knight, black_rook, black_queen])
      end
    end

    context 'when the target cannot be taken' do

      it 'returns an empty list' do
        target = white_king
        colour = white_king.colour
        result = validator.identify_target_locking_candidates(target, colour)
        expect(result).to be_empty
      end
    end

  end

  describe '#check?' do
    let(:white_pawn) { Pawn.new(:white, [1, 2]) }
    let(:white_knight) { Knight.new(:white, [4, 0]) }
    let(:white_rook) { Rook.new(:white, [5, 4]) }
    let(:white_rook_two) { Rook.new(:white, [2, 6]) }
    let(:white_queen) { Queen.new(:white, [5, 5]) }
    let(:black_pawn) { Pawn.new(:black, [5, 2]) }

    context 'when a target can be taken in many ways' do

      let(:check_board) {
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, white_pawn, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, white_rook_two, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [white_knight, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, black_pawn, nil, white_rook, white_queen, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      }

      before { validator.spectator.instance_variable_set(:@board, check_board) }
      before { validator.instance_variable_set(:@current_board, check_board) }

      it 'returns true' do
        target = black_pawn
        colour = black_pawn.colour
        result = validator.check?(target, colour)
        expect(result).to be true
      end
    end

    # shielded/blocked or not visible to another piece
    context 'when a piece cannot be taken' do
      let(:white_pawn) { Pawn.new(:white, [1, 3]) }
      let(:white_queen) { Queen.new(:white, [0, 3]) }
      let(:white_rook) { Rook.new(:white, [5, 4]) }
      let(:black_pawn) { Pawn.new(:black, [4, 3]) }
      let(:no_check_board) {
        [
          [nil, nil, nil, white_queen, nil, nil, nil, nil],
          [nil, nil, nil, white_pawn, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, black_pawn, nil, nil, nil, nil],
          [nil, nil, nil, nil, white_rook, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      }

      before { validator.spectator.instance_variable_set(:@board, no_check_board) }
      before { validator.instance_variable_set(:@current_board, no_check_board) }

      it 'returns false' do
        target = black_pawn
        colour = black_pawn.colour
        result = validator.check?(target, colour)
        expect(result).to be false
      end
    end
  end

  describe '#unblocked_path' do
    let(:black_queen) { Queen.new(:black, [1, 2]) }
    let(:black_pawn) { Pawn.new(:black, [2, 2]) }
    let(:black_knight) { Knight.new(:black, [4, 5]) }
    let(:white_rook) { Rook.new(:white, [4, 2]) }
    let(:white_pawn) { Pawn.new(:white, [4, 4]) }
    let(:white_pawn_two) { Pawn.new(:white, [6, 1]) }
    let(:white_bishop) { Bishop.new(:white, [3, 4]) }
    let(:example_board) {
      [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, black_queen, nil, nil, nil, nil, nil],
        [nil, nil, black_pawn, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, white_bishop, nil, nil, nil],
        [nil, nil, white_rook, nil, white_pawn, black_knight, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, white_pawn_two, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }

    before { validator.instance_variable_set(:@current_board, example_board) }

    it 'reports the right path for the Pawns' do
      result_black = validator.unblocked_path(black_pawn)
      result_white = validator.unblocked_path(white_pawn)
      result_white_two = validator.unblocked_path(white_pawn_two)
      expect(result_black).to eq [[3, 2]]
      expect(result_white).to be_empty
      expect(result_white_two).to match_array([[5, 1], [4, 1]])
    end

    it 'reports the right path for the Knight' do
      result = validator.unblocked_path(black_knight)
      arr = [
        [5, 7], [6, 6], [3, 7], [2, 6], [6, 4],
        [5, 3], [2, 4], [3, 3]
      ]
      expect(result).to match_array(arr)
    end

    it 'reports the right path for the Bishop' do
      result = validator.unblocked_path(white_bishop)
      arr = [
        [2, 3], [1, 2], [2, 5], [1, 6],
        [0, 7], [4, 5], [4, 3], [5, 2]
      ]
      expect(result).to match_array(arr)
    end

    it 'reports the right path for the Queen' do
      result = validator.unblocked_path(black_queen).sort
      arr = [
        [0, 1], [0, 2], [0, 3], [1, 0], [1, 1], [1, 3], [1, 4], [1, 5],
        [1, 6], [1, 7], [2, 1], [3, 0], [2, 3], [3, 4]
      ]
      expect(result).to match_array arr
    end

    it 'reports the right path for the Rook' do
      result = validator.unblocked_path(white_rook)
      arr = [
        [3, 2], [2, 2], [4, 3], [4, 1],
        [4, 0], [5, 2], [6, 2], [7, 2]
      ]
      expect(result).to match_array(arr)
    end

  end

  describe '#en_passant_conditions?' do
    let(:white_pawn) { Pawn.new(:white, [3, 4]) }
    let(:black_pawn) { Pawn.new(:black, [4, 2]) }
    let(:static_white_pawn) { Pawn.new(:white, [4, 1]) }
    let(:static_black_pawn) { Pawn.new(:black, [3, 5]) }
    let(:en_passant_board) {
      [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, white_pawn, static_black_pawn, nil, nil],
        [nil, static_white_pawn, black_pawn, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }
    before { validator.instance_variable_set(:@current_board, en_passant_board) }
    context 'when the destination is valid and is empty' do
      it 'calls #possible_en_passant? and returns true' do
        destination = [2, 5]
        result = validator.obtain_adjacent_piece(white_pawn, destination)
        expect(result).to match_array([static_black_pawn, 5])
      end
    end

    context 'when the destination is invalid but is empty' do
      it 'returns false and does not call #possible_en_passant?' do
        destination = [4, 4]
        expect(validator).not_to receive(:possible_en_passant?)
        result = validator.obtain_adjacent_piece(black_pawn, destination)
        expect(result).to be false
      end
    end
    
  end

  describe '#past_pawn_double_move?' do
    let(:white_pawn) { Pawn.new(:white, [3, 3]) }
    let(:valid_black_pawn) { Pawn.new(:black, [1, 3]) }
    let(:past_board) {
      [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, valid_black_pawn, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, white_pawn, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }

    before { validator.instance_variable_set(:@past_board, past_board) }

    context 'when a pawn moved two squares from it\'s starting rank' do
      it 'returns :en_passant_move' do
        pawn = white_pawn
        result = validator.past_pawn_double_move?(pawn, 4)
        expect(result).to eq :en_passant_move
      end
    end

    context 'when a pawn did not move two squares from it\'s starting rank' do
      it 'returns false' do
        pawn = white_pawn
        result = validator.past_pawn_double_move?(pawn, 3)
        expect(result).to be false
      end
    end

  end

  describe '#castling' do
    
  end

  describe '#castling' do
    let(:black_king) { King.new(:black, [0, 4]) }
    let(:black_rook) { Rook.new(:black, [0, 7]) }
    let(:black_knight) { Knight.new(:black, [4, 2]) }
    let(:white_queen) { Queen.new(:white, [3, 6]) }
    let(:white_king) { King.new(:white, [7, 4]) }
    let(:white_rook) { Rook.new(:white, [7, 0]) }
    let(:castle_board) {
      [
        [nil, nil, nil, nil, black_king, nil, nil, black_rook],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, white_queen, nil],
        [nil, nil, black_knight, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [white_rook, nil, nil, nil, white_king, nil, nil, nil]
      ]
    }

    before { validator.instance_variable_set(:@current_board, castle_board) }
    before { spectator.instance_variable_set(:@board, castle_board) }
    context 'when no castling moves would result in check (valid move)' do
      it 'returns true' do
        # coords = [[7, 2], [7, 1]]
        # direction = [0, -1]
        # castle_rank = 7
        # colour = :white
        # result = validator.valid_castle?(colour, coords, direction, castle_rank)
        destination = [7, 1]
        result = validator.castling(white_king, destination)
        expect(result).to eq [7, 0, 7, 2]
      end
    end

    context 'when one or more castling moves would result in check (invalid castle)' do
      it 'returns false' do
        # coords = [[0, 4], [0, 5]]
        # direction = [0, 1]
        # castle_rank = 7
        # colour = :black
        destination = [0, 6]
        result = validator.castling(black_king, destination)
        expect(result).to be false
      end
    end

  end

  describe '#king_in_check?' do

    context 'when a king is on the same rank as a rook' do

      let(:white_rook) { Rook.new(:white, [2, 4]) }
      let(:black_king) { King.new(:black, [5, 4]) }
      let(:black_pawn) { Pawn.new(:black, [6, 4]) }
      let(:check_board) {
                    [
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, white_rook, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, black_king, nil, nil, nil],
                      [nil, nil, nil, nil, black_pawn, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil]
                    ]
                  }

      before { validator.instance_variable_set(:@current_board, check_board) }
      before { validator.spectator.instance_variable_set(:@board, check_board) }
      it 'should be check' do
        colour = black_king.colour
        result = validator.king_in_check?(colour)
        expect(result).to be true
      end
    end

    context 'when a king cannot be taken by any attacking pieces' do
      let(:white_rook) { Rook.new(:white, [4, 0]) }
      let(:white_pawn) { Pawn.new(:white, [7, 2]) }
      let(:white_bishop) { Bishop.new(:white, [0, 5]) }
      let(:white_knight) { Knight.new(:white, [4, 7]) }
      let(:white_queen) { Queen.new(:white, [7, 7]) }
      let(:black_king) { King.new(:black, [5, 4]) }
      let(:no_check_board) {
        [
          [nil, nil, nil, nil, nil, white_bishop, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [white_rook, nil, nil, nil, nil, nil, nil, white_knight],
          [nil, nil, nil, nil, black_king, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, white_pawn, nil, nil, nil, nil, white_queen]
        ]
      }
      before { validator.instance_variable_set(:@current_board, no_check_board) }
      before { validator.spectator.instance_variable_set(:@board, no_check_board) }
      it { should_not be_king_in_check(:black) }
    end


  end

  describe '#stalemate?' do
    context 'when a king is not check and has no viable moves' do
      let(:black_rook) { Rook.new(:black, [0, 5]) }
      let(:black_rook_two) { Rook.new(:black, [0, 7]) }
      let(:black_queen) { Queen.new(:black, [6, 3]) }
      let(:white_king) { King.new(:white, [7, 6]) }
      let(:stale_board) {
        [
          [nil, nil, nil, nil, nil, black_rook, nil, black_rook_two],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, black_queen, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, white_king, nil]
        ]
      }

      before { validator.instance_variable_set(:@current_board, stale_board) }
      before { validator.spectator.instance_variable_set(:@board, stale_board) }
      it { should be_stalemate(:white) }
    end

  end

  describe '#checkmate?' do
    
    context 'when a king has no viable moves' do
      let(:black_knight) { Knight.new(:black, [4, 5]) }
      let(:black_queen) { Queen.new(:black, [6, 6]) }
      let(:white_king) { King.new(:white, [7, 6]) }
      let(:checkmate_board) {
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, black_knight, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, black_queen, nil],
          [nil, nil, nil, nil, nil, nil, white_king, nil]
        ]
      }
      before { validator.instance_variable_set(:@current_board, checkmate_board) }
      before { validator.spectator.instance_variable_set(:@board, checkmate_board) }
      it 'should call #no_way_out' do
        expect(validator).to receive(:no_way_out?)
        validator.checkmate?(:white, black_queen)
      end
      it { should be_checkmate(:white, black_queen) }
    end

    context 'when a king has at least on move available' do

      let(:black_knight) { Knight.new(:black, [4, 1]) }
      let(:black_queen) { Queen.new(:black, [7, 4]) }
      let(:white_king) { King.new(:white, [5, 4]) }
      let(:no_checkmate_board) {
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, black_knight, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, white_king, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, black_queen, nil, nil, nil]
        ]
      }
      before { validator.instance_variable_set(:@current_board, no_checkmate_board) }
      before { validator.spectator.instance_variable_set(:@board, no_checkmate_board) }

      it { should_not be_checkmate(:white, black_queen) }
    end

    context 'when the last checking piece can be interrupted' do
      let(:black_rook) { Rook.new(:black, [6, 4]) }
      let(:black_queen) { Queen.new(:black, [7, 1]) }
      let(:white_king) { King.new(:white, [7, 6]) }
      let(:white_rook) { Rook.new(:white, [6, 2]) }
      let(:checkmate_board) {
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, white_rook, nil, black_rook, nil, nil, nil],
          [nil, black_queen, nil, nil, nil, nil, white_king, nil]
        ]
      }
      before { validator.instance_variable_set(:@current_board, checkmate_board) }
      before { validator.spectator.instance_variable_set(:@board, checkmate_board) }

      it { should_not be_checkmate(:white, black_queen) }
    end

    context 'when king in check and last piece can be taken by another piece' do
      let(:black_rook) { Rook.new(:black, [6, 4]) }
      let(:black_queen) { Queen.new(:black, [7, 1]) }
      let(:white_king) { King.new(:white, [7, 6]) }
      let(:white_rook) { Rook.new(:white, [0, 1]) }
      let(:checkmate_board) {
        [
          [nil, white_rook, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, black_rook, nil, nil, nil],
          [nil, black_queen, nil, nil, nil, nil, white_king, nil]
        ]
      }
      before { validator.instance_variable_set(:@current_board, checkmate_board) }
      before { validator.spectator.instance_variable_set(:@board, checkmate_board) }

      it { should_not be_checkmate(:white, black_queen) }
    end
  end

end