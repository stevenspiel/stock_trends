require 'rails_helper'

describe Market do
  describe 'associations' do
    it { should have_many(:syms).dependent(:destroy) }
    it { should have_many(:days).through(:syms) }
  end

  describe '#to_s' do
    let(:subject) { described_class.new(name: 'foo') }
    it 'returns the name' do
      expect(subject.to_s).to eq(subject.name)
    end
  end
end
