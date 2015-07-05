require 'rails_helper'

describe Tick do
  describe 'associations' do
    it { should belong_to(:day) }
  end

  describe 'delegations' do
    it { should delegate_method(:sym).to(:day) }
  end
end
