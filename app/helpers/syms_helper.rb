module SymsHelper
  def sym_info(sym)
    "#{sym.volatility.round(4)}% volatility" if sym.volatility
  end

  def sym_title(sym)
    "#{sym.name} #{number_to_currency sym.current_price}"
  end
end
