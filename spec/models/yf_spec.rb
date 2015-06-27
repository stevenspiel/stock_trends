require 'rails_helper'
require 'pry-nav'

describe Yf do
  let(:sym) { Sym.new }
  let(:full_csv) do
    file = File.join(Rails.root, 'spec', 'lib', 'a.csv')
    File.read(file)
  end
  let(:tick) do
    Tick.new(
      time: '2015-04-05 20:31:52 -0400'.to_datetime,
      amount: BigDecimal.new(15)
    )
  end

  describe '#intraday' do
    before(:each) do
      allow(subject).to receive(:filled_in_gaps).and_return([])
      allow(subject).to receive(:csv).and_return(full_csv)
    end

    it 'returns new ticks for all previous days' do
      last_tick = tick.time.to_date
      expect(subject.intraday(sym, 'sma', 15, last_tick).size).to eq(1137)
    end

    it 'returns new ticks for all days after last tick' do
      last_tick = '2015-04-10'.to_date
      expect(subject.intraday(sym, 'sma', 15, last_tick).size).to eq(869)
    end
  end

  describe '#filled_in_gaps' do
    allow(Date).to receive(:today).and_return('Apr 21, 2015'.to_date) # Tuesday

    context 'opens and closes are present' do
      allow(subject).to receive(:opens_and_closes).and_return([
        Tick.new(time: 'Apr 17 2015'.to_datetime, amount: 1),
      ])
      it 'returns a pair of ticks for missing days' do
        last_tick = 'Apr 16, 2105'.to_date # Thursday
        expect(filled_in_gaps(last_tick, sym, []))
      end
    end
  end

  describe '#end_points' do

  end
end
