# frozen-string-literal: true

require_relative './../../lib/rules/move_validation'
require_relative './../../lib/board'
require_relative './../../lib/pieces/knight'
require_relative './../../lib/pieces/queen'
require_relative './../../lib/pieces/king'
require_relative './../../lib/pieces/rook'

describe ChessBoard do

  describe '#contains_piece?' do
    subject(:dummy_class) { Class.new { extend MoveValidation } }
    let(:mini_board) { [[' x ', '  '], ['  ', ' x ']] }

    context 'when give an empty square and then an occupied square' do
      it 'returns true then false' do
        valid_destination = mini_board[0][0]
        valid_result = dummy_class.contains_piece?(valid_destination)
        expect(valid_result).to be true

        invalid_destination = mini_board[0][1]
        invalid_result = dummy_class.contains_piece?(invalid_destination)
        expect(invalid_result).to be false
      end
    end
  end

  describe '#in_check?' do
    subject(:board_in_check) { described_class.new(board) }
    let(:white_rook) { instance_double(Rook) }
    let(:black_king) { instance_double(King) }
    
    context 'when a king and rook are on the same rank' do
      let(:board) {
                    [
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', white_rook, '  ', '  ', black_king, '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
                      ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
                    ]
                  }
      it { should be_in_check }
    end

    context 'when a king is on a different rank and file to a rook' do
      let(:board) {
        [
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', white_rook, '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', black_king, '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  ']
        ]
      }
      it { should_not be_in_check }
    end


  end

  describe '#in_checkmate?' do
    subject(:board_in_check) { described_class.new(board) }
    let(:black_knight) { instance_double(Knight) }
    let(:black_queen) { instance_double(Queen) }
    let(:white_king) { instance_double(King) }

    context 'when a king has no viable moves' do
      let(:board) {
        [
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', black_knight, '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', black_queen, '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', white_king, '  ']
        ]
      }
      it { should be_in_checkmate }
    end

    context 'when a king has at least on move available' do
      let(:board) {
        [
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', black_knight, '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', white_king, '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', '  ', '  ', '  ', '  '],
          ['  ', '  ', '  ', '  ', black_queen, '  ', '  ', '  ']
        ]
      }
      it { should_not be_in_checkmate }
    end
  end

end