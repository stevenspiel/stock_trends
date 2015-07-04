module SymsHelper
  def sym_info(sym)
    "#{sym.volatility.round(4)}% volatility" if sym.volatility
  end

  def sym_title(sym)
    "#{sym.name} #{number_to_currency sym.current_price}"
  end

  def historical_title(sym)
    dates = sym.min_and_max_historical_dates
    min = dates[:min].present? ? dates[:min].strftime('%Y') : '?'
    max = dates[:max].present? ? dates[:max].strftime('%Y') : '?'
    "#{min} - #{max}"
  end
end
