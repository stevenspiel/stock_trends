require 'rails_helper'

describe Sym do
  describe 'associations' do
    it { should belong_to(:market) }
    it { should have_many(:days).order(:date).dependent(:destroy) }
    it { should have_many(:ticks).through(:days) }
    it { should have_many(:historical_datums).order(:date).dependent(:destroy) }
  end

  describe '#to_s' do
    let(:subject) { described_class.new(name: 'foo') }
    it 'returns the name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end
end
