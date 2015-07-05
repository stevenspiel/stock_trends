require 'rails_helper'

describe Api do
  describe 'associations' do
    it { should have_many(:syms) }
  end

  describe '#to_s' do
    let(:subject) { described_class.new(name: 'foo') }
    it 'returns the name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end

  describe 'model_class' do
    context 'when Yahoo' do
      let(:subject) { described_class.new(name: 'Yahoo') }
      it 'returns Yf class' do
        expect(subject.model_class).to eq(:Yf)
      end
    end
    context 'when Quandl' do
      let(:subject) { described_class.new(name: 'Quandl') }
      it 'returns Yf class' do
        expect(subject.model_class).to eq(:Q)
      end
    end
    context 'when Market On Demand' do
      let(:subject) { described_class.new(name: 'Market On Demand') }
      it 'returns Yf class' do
        expect(subject.model_class).to eq(:Mod)
      end
    end
    context 'when Trade King' do
      let(:subject) { described_class.new(name: 'Trade King') }
      it 'returns Yf class' do
        expect(subject.model_class).to eq(:Tk)
      end
    end
  end
end
