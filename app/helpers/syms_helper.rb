module SymsHelper
  def sym_info(sym)
    "#{sym.volatility.round(4)}% volatility" if sym.volatility
  end

  def sym_title(sym)
    "#{sym.name} #{number_to_currency sym.current_price}"
  end

  def historical_title(sym)
    dates = sym.cached(:min_and_max_historical_dates)
    min_year = dates[:min].strftime('%Y')
    max_year = dates[:max].strftime('%Y')
    "#{min_year} - #{max_year}"
  end
end
