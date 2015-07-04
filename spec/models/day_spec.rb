require 'rails_helper'

describe Day do
  describe 'associations' do
    it { should belong_to(:sym) }
    it { should have_many(:ticks).inverse_of(:day).dependent(:destroy).order(:time) }
  end

  describe 'validations' do
    it { should validate_presence_of :sym }
    it { should validate_presence_of :date }
  end

  describe 'delegations' do
    it { should delegate_method(:market).to(:sym) }
  end
end
