class Log
  BATCH_SIZE = 500

  def initialize(*markets)
    @markets = markets.empty? ? Market.by_importance : markets
    @tk = Tk.new
    @q = Q.new
    @yf = Yf.new
    ActiveRecord::Base.logger = nil # suppress sql output
  end

  def intraday(api: @yf, scope: :all, where: nil)
    # cron runs nightly
    @markets.each do |market|
      # First tick is opening price and last one is closing price
      market.syms.send(scope).where(where).find_each do |sym|
        begin
          print "Logging Intraday Ticks for #{sym.market} - #{sym.padded}"
          api.log_intraday_history(sym)
        rescue => error
          binding.pry
        end
        puts percent_complete(scope: :greater_than, sym: sym)
      end
      Curator.run!(market)
    end
    nil
  end

  def prices(api: @yf, scope: :all, where: [])
    @markets.each do |market|
      market.syms.send(scope).where(where).in_groups_of(BATCH_SIZE) do |group|
        begin
          symbols = group.compact.map(&:name)
          prices = api.prices(symbols)
          prices.each do |quote|
            ask = quote[:ask]
            next unless ask.present?
            sym = Sym.find_by(name: quote[:symbol])
            sym.update_attributes!(current_price: ask)
            puts "#{sym.padded} - $#{sym.current_price}"
          end
        rescue => error
          binding.pry
        end
      end
    end
    nil
  end

  def historical(api: @q, scope: :pending_historical, where: nil)
    @markets.each do |market|
      market.syms.send(scope).where(where).find_each do |sym|
        begin
          print "Logging Historical Data for #{sym.market} - #{sym.padded('.')}..."
          result = api.log_historical(sym)
          return if api.not_successful?(result) && api.handle_error(result, sym)
        rescue => error
          binding.pry
        end
        puts percent_complete(scope: scope)
      end
    end
    nil
  end

  def volatility
    Sym.successful_intraday.each do |sym|
      begin
        volatility = sym.calculate_volatility
        next unless volatility
        sym.update_column(:volatility, volatility)
        puts "#{sym.padded} - #{sym.volatility}%"
      rescue => error
        binding.pry
      end
    end
    nil
  end

  private

  def percent_complete(scope: :all, sym: nil)
    remaining = sym ? Sym.send(scope, sym).count : Sym.send(scope).count
    all = Sym.count
    completed = all - remaining
    percent_complete = (completed.to_f /  all) * 100
    " #{percent_complete.round(2)}%"
  end
end
