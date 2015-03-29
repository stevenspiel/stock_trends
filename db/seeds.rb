require_relative '../lib/market_symbols'

MARKET_SYMBOLS.each do |symbols_hash|
  symbols_hash.each do |market, syms|
    m = Market.create!(name: market, hour_opens: 9.5, hour_closes: 16)
    puts "Adding Symbols for #{market}..."
    syms.each do |sym|
      m.syms.create!(name: sym[0], full_name: sym[1])
    end
  end
end

['Yahoo', 'Market On Demand', 'Quandl', 'Nasdaq', 'Trade King'].each do |api|
  Api.create!(name: api)
end


