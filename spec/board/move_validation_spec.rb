# frozen-string-literal: true

require_relative './../../lib/rules/move_validation'
require_relative './../../lib/rules/movement'
require_relative './../../lib/spectator'
require_relative './../../lib/pieces/knight'
require_relative './../../lib/pieces/queen'
require_relative './../../lib/pieces/king'
require_relative './../../lib/pieces/rook'

describe MoveValidator do
  
  subject(:validator) { described_class.new(board, spectator, mover) }
  let(:spectator) { Spectator.new(mover) }
  let(:mover) { Movement.new }
  let(:board) { [] }
    
  describe '#find_king' do
    
    let(:black_king) { instance_double(King, colour: :black) }
    let(:white_king) { instance_double(King, colour: :white) }
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
    before { spectator.instance_variable_set(:@board, both_kings_board) }

    context 'when no colour is specified' do

      it 'returns a list of each king' do
        result = validator.find_king
        result_length = result.length
        result_colours = result.map(&:colour)
        expect(result_length).to eq 2
        expect(result).to all(be_a(King))
        expect(result_colours).to match_exactly(%i[white black])
      end

    end

    context 'when a colour is specified' do

      it 'returns a list containing one king' do
        result_white = validator.find_king(:white)
        result_black = validator.find_king(:black)
        expect(result_black).to eq [black_king]
        expect(result_white).to eq [white_king]
      end

    end

  end

  describe '#identify_target_locking_candidates' do
    let(:black_knight) { instance_double(Knight, colour: :black, location: [3, 4]) }
    let(:black_rook) { instance_double(Rook, colour: :black, location: [5, 2]) }
    let(:black_queen) { instance_double(Queen, colour: :black, location: [5, 1]) }
    let(:white_rook) { instance_double(Rook, colour: :white, location: [5, 6]) }
    let(:white_queen) { instance_double(Queen, colour: :white, location: [5, 4]) }
    let(:white_king) { instance_double(King, colour: :white, location: [0, 0]) }
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
    before { spectator.instance_variable_set(:@board, target_locking_board) }
    context 'when a target is in direction of a piece' do

      it 'returns a list of pieces that \'look\' at the target' do
        target = white_queen
        colour = white_queen.colour
        result = validator.identify_target_locking_candidates(target, colour)
        expect(result).to match_exactly([black_knight, black_rook])
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
    let(:white_pawn) { instance_double(Pawn, colour: :white, location: [1, 2]) }
    let(:white_knight) { instance_double(Knight, colour: :white, location: [4, 0]) }
    let(:white_rook) { instance_double(Rook, colour: :white, location: [5, 4]) }
    let(:white_rook_two) { instance_double(Rook, colour: :white, location: [2, 6]) }
    let(:white_queen) { instance_double(Queen, colour: :white, location: [5, 5]) }
    let(:black_pawn) { instance_double(Pawn, colour: :black, location: [5, 2]) }

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

      before { spectator.instance_variable_set(:@board, check_board) }

      it 'returns true' do
        target = black_pawn
        colour = black_pawn.colour
        result = validator.check?(target, colour)
        expect(result).to be_true
      end
    end

    # shielded/blocked or not visible to another piece
    context 'when a piece cannot be taken' do
      let(:white_pawn) { instance_double(Pawn, colour: :white, location: [1, 3]) }
      let(:white_queen) { instance_double(Queen, colour: :white, location: [0, 3]) }
      let(:white_rook) { instance_double(Rook, colour: :white, location: [5, 4]) }
      let(:black_pawn) { instance_double(Pawn, colour: :black, location: [4, 3]) }
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

      before { spectator.instance_variable_set(:@board, no_check_board) }

      it 'returns false' do
        target = black_pawn
        colour = black_pawn.colour
        result = validator.check?(target, colour)
        expect(result).to be_false
      end
    end
  end

  describe '#unblocked_path' do
    let(:black_queen) { instance_double(Queen, colour: :black, location: [1, 2]) }
    let(:black_pawn) { instance_double(Pawn, colour: :black, location: [2, 2]) }
    let(:black_knight) { instance_double(Knight, colour: :black, location: [4, 5]) }
    let(:white_rook) { instance_double(Rook, colour: :white, location: [4, 2]) }
    let(:white_pawn) { instance_double(Pawn, colour: :white, location: [4, 4]) }
    let(:example_board) {
      [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, black_queen, nil, nil, nil, nil, nil],
        [nil, nil, black_pawn, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, white_rook, nil, white_pawn, black_knight, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }



    it 'reports the right path for the Pawns' do
      negate = false
      result_black = validator.unblocked_path(black_pawn, negate)
      result_white = validator.unblocked_path(white_pawn, negate)
      expect(result_black).to be_empty
      expect(result_white).to match_exactly([[3, 4]])
    end

    it 'reports the right path for the Knight' do
      
    end

    it 'reports the right path for the Queen' do
      
    end

    it 'reports the right path for the Rook' do
      
    end

  end


  describe '#pawn_move' do
    
  end

  describe '#en_passant_conditions' do
    
  end


  # past_board
  describe '#past_pawn_double_move' do
    
  end

  describe '#castling' do
    
  end

  describe '#valid_castle?' do
    
  end

  # one-dimention vs two-dimention and report direction assertions
  describe '#square_in_right_direction?' do
    
  end

  describe '#vertical_horizontal?' do
    
  end

  describe '#valid_scalers?' do
    
  end

  describe '#calculate_scalers' do
    
  end

  describe 'calculate_component_difference' do
    
  end

  describe '#king_in_check?' do

    context 'when a king and rook are on the same rank' do

      let(:white_rook) { instance_double(Rook, location: [5, 1], colour: :white) }
      let(:black_king) { instance_double(King, location: [5, 4], colour: :black) }

      let(:check_board) {
                    [
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, white_rook, nil, nil, black_king, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil],
                      [nil, nil, nil, nil, nil, nil, nil, nil]
                    ]
                  }

      before { validator.instance_variable_set(:@board, check_board) }

      it { should be_king_in_check(:black) }
    end

    context 'when a king is on a different rank and file to a rook' do
      let(:white_rook) { instance_double(Rook, location: [4, 1], colour: :white) }
      let(:no_check_board) {
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, white_rook, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, black_king, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      }
      before { validator.instance_variable_set(:@board, no_check_board) }
      it { should_not be_king_in_check(:black) }
    end


  end

  describe '#checkmate?' do
    
    context 'when a king has no viable moves' do
      let(:black_knight) { instance_double(Knight, location: [4, 5], colour: :black) }
      let(:black_queen) { instance_double(Queen, location: [6, 6], colour: :black) }
      let(:white_king) { instance_double(King, location: [7, 6], colour: :white) }

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
      before { validator.instance_variable_set(:@board, checkmate_board) }
      it { should be_checkmate(:white) }
    end

    context 'when a king has at least on move available' do

      let(:black_knight) { instance_double(Knight, location: [4, 1], colour: :black) }
      let(:black_queen) { instance_double(Queen, location: [7, 4], colour: :black) }
      let(:white_king) { instance_double(King, location: [5, 4], colour: :white) }  

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
      before { validator.instance_variable_set(:@board, no_checkmate_board) }
      it { should_not be_checkmate(:white) }
    end
  end

end