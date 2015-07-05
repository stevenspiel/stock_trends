require 'rails_helper'

describe HistoricalDatum do
  describe 'associations' do
    it { should belong_to(:sym) }
  end
end
