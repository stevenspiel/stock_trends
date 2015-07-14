class Log
  BATCH_SIZE = 500

  def initialize(*markets)
    @markets = markets.empty? ? Market.by_importance : markets
    @tk = Tk.new
    @q = Q.new
    @yf = Yf.new
    @sym_count = Sym.count
    ActiveRecord::Base.logger = nil # suppress sql output
  end

  def intraday(api: @yf)
    # cron runs nightly
    Sym.ordered.find_each do |sym|
      # First tick is opening price and last one is closing price
      begin
        print "Logging Intraday Ticks for #{sym.padded}"
        success = api.log_intraday_history(sym)
        sym.reset_cached_data(:five_weeks, :historical_data, :min_and_max_historical_dates) if success
      rescue => e
        binding.pry if Rails.env.development?
      end
      puts percent_complete(scope: :greater_than, sym: sym)
    end
    @markets.each { |market| Curator.run!(market) }
    nil
  end

  def prices(api: @yf)
    Sym.ordered.in_groups_of(BATCH_SIZE) do |group|
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
      rescue => e
        puts e
        binding.pry if Rails.env.development?
      end
    end
    nil
  end

  def historical(api: @q)
    Sym.pending_historical.ordered.find_each do |sym|
      begin
        print "Logging Historical Data for #{sym.padded('.')}..."
        result = api.log_historical(sym)
        return if api.not_successful?(result) && api.handle_error(result, sym)
        sym.reset_cached_data(:historical_data)
      rescue => e
        binding.pry if Rails.env.development?
      end
      puts percent_complete(scope: :pending_historical)
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
      rescue => e
        binding.pry if Rails.env.development?
      end
    end
    nil
  end

  private

  def percent_complete(scope: :all, sym: nil)
    remaining = sym ? Sym.send(scope, sym).count : Sym.send(scope).count
    completed = @sym_count - remaining
    percent_complete = (completed.to_f /  @sym_count) * 100
    " #{percent_complete.round(2)}%"
  end
end
