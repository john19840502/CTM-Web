require 'calculator/lowest_fico_score'

describe LowestFicoScore do
  describe 'calculation scenarios' do
    it 'should return 0 when fico scores is an empty array' do
      expect(LowestFicoScore.new([]).call).to eq(0)
    end

    it 'should raise an error if fico_scores is not an array' do
      expect{LowestFicoScore.new(849,"385",415,"500")}.to raise_error(ArgumentError)
    end

    it 'should return the lowest number when passed an array of integers' do
      expect(LowestFicoScore.new([849,415,500,700]).call).to eq(415)
    end

    it 'should return the lowest number when passed an array of integers and strings' do
      expect(LowestFicoScore.new([849,"385",415,"500"]).call).to eq(385)
    end
  end
end
