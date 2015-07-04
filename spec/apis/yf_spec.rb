require 'rails_helper'

RSpec.describe Yf, type: :model do
  let(:sym) { Sym.new }
  let(:full_csv) do
    CSV.parse(File.read(File.join(Rails.root, 'spec', 'lib', 'a.csv')))
  end
  let(:tick) do
    Tick.new(
      time: '2015-04-05 20:31:52 -0400'.to_datetime,
      amount: BigDecimal.new(15)
    )
  end

  describe '#intraday' do
    before(:each) do
      allow(subject).to receive(:csv_data).and_return(full_csv)
    end
  end
end
