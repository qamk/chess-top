# frozen-string-literal: true

require_relative './../../lib/translator'

describe Translator do

  let(:translator) { described_class.new }
  
  describe '#valid_notation?' do
    let(:valid_notation) { 'a5' }
    let(:invalid_notation) { 'aaa4' }

    context 'when given notation' do
      it 'returns true for valid notation, otherwise false' do
        valid_result = translator.valid_notation?(valid_notation)
        invalid_result = translator.valid_notation?(invalid_notation)
        expect(valid_result).to be true
        expect(invalid_result).to be false
      end
    end
  end

  describe '#translate_location' do
    context 'when given a5, b2 and e7' do
      it 'returns  [4, 0], [1, 1] and [6, 4]' do
        first = 'a5'
        second = 'b2'
        third = 'e7'
        first_result = translator.translate_location(first)
        second_result = translator.translate_location(second)
        third_result = translator.translate_location(third)
        expect(first_result).to eq [4, 0]
        expect(second_result).to eq [1, 1]
        expect(third_result).to eq [6, 4]
      end
    end
  end
end