# frozen-string-literal: true

require_relative './../../lib/board'
require_relative './../../lib/pieces/knight'
require_relative './../../lib/pieces/bishop'
require_relative './../../lib/pieces/rook'
require_relative './../../lib/pieces/queen'
require_relative './../../lib/pieces/king'
require_relative './../../lib/pieces/pawn'

describe Board do

  let(:chess_board) { described_class.new }

  describe '#create_starting_board' do
    context 'when called' do
      it 'creates the chess starting board' do
        chess_board.create_starting_board
        start_board = chess_board.instance_variable_get(:@board)
        unique_pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
        unique_row_indices = { black: 0, white: 7 }
        pawn_row = { black: 1, white: 6 }
        unique_black_row = start_board[unique_row_indices[:black]]
        unique_white_row = start_board[unique_row_indices[:white]]
        black_pawn_row = start_board[pawn_row[:black]]
        white_pawn_row = start_board[pawn_row[:white]]
        expect(unique_black_row.map(&:class)).to eq unique_white_row.map(&:class)
        expect(unique_white_row.map(&:class)).to eq unique_pieces
        expect(black_pawn_row).to all(be_a(Pawn))
        expect(white_pawn_row).to all(be_a(Pawn))
        expect(unique_black_row.map(&:colour)).to all(be(:black))
        expect(white_pawn_row.map(&:colour)).to all(be(:white))
      end
    end
  end

  describe '#promote' do
    let(:white_pawn) { Pawn.new(:white, [0, 3]) }
    let(:rank) { 0 }
    let(:file) { 3 }
      # Reference board
      # [
      #   [nil, nil, nil, white_pawn, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil],
      #   [nil, nil, nil, nil, nil, nil, nil, nil]
      # ]

    context 'if called with :q, :r, :b or :n' do
      it 'changes the a pawn into a Queen (:q)' do
        chess_board.promote(white_pawn, :q)
        board = chess_board.instance_variable_get(:@board)
        pawn_location = board[rank][file]
        expect(pawn_location).to be_a(Queen)
      end

      it 'changes the a pawn into a Rook (:r)' do
        chess_board.promote(white_pawn, :r)
        board = chess_board.instance_variable_get(:@board)
        pawn_location = board[rank][file]
        expect(pawn_location).to be_a(Rook)
      end

      it 'changes the a pawn into a Bishop (:b)' do
        chess_board.promote(white_pawn, :b)
        board = chess_board.instance_variable_get(:@board)
        pawn_location = board[rank][file]
        expect(pawn_location).to be_a(Bishop)
      end

      it 'changes the a pawn into a Knight (:n)' do
        chess_board.promote(white_pawn, :n)
        board = chess_board.instance_variable_get(:@board)
        pawn_location = board[rank][file]
        expect(pawn_location).to be_a(Knight)
      end
    end
  end

  describe '#update_castle' do
    let(:destination) { [0, 7, 0, 5] }
    let(:black_rook) { Rook.new(:black, [0, 7]) }
    let(:board) {
        [
        [nil, nil, nil, nil, nil, nil, nil, black_rook],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil]
      ]
    }
    before { chess_board.instance_variable_set(:@board, board) }
    context 'when called' do
      it 'updates a piece\'s (rook) location' do
        expect(chess_board).to receive(:update_board).with(black_rook, [0, 5])
        chess_board.update_castle(destination)
      end
    end

  end

  describe '#update_board' do
    let(:piece) { Bishop.new(:white, [7, 1]) }
    let(:rank) { 4 }
    let(:file) { 4 }
    let(:destination) { [rank, file] }

    context 'when called' do
      it 'updates a piece\'s location and @old_board' do
        past_board = chess_board.instance_variable_get(:@board) 
        chess_board.update_board(piece, destination)

        old_board = chess_board.instance_variable_get(:@old_board)
        current_board = chess_board.instance_variable_get(:@board)
        updated_piece = current_board[rank][file]
        expect(old_board).to eq past_board
        expect(updated_piece).to be_a(Bishop)
        expect(updated_piece.location).to eq [rank, file]
      end
    end
  end

end