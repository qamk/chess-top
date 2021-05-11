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

    context 'when no colour is specified' do

      before { spectator.instance_variable_set(:@board, both_kings_board) }

      it 'returns a list of each king' do
        result = validator.find_king
        result_length = result.length
        result_colours = result.map(&:colour)
        expect(result_length).to eq 2
        expect(result).to all(be_a(King))
        expect(result_colours).to match_exactly(%i[white black])
      end



    end

  end

  describe '#identify_target_locking_candidates' do
    
  end

  describe '#in_sight' do
    
  end

  describe '#no_way_out?' do
    
  end

  describe '#direction_to_target_index' do
    
  end

  describe '#unblocked_path' do
    
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