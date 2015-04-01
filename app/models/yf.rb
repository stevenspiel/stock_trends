class Yf
  require 'open-uri'

  def new
    @api = Api.yahoo
  end

  def id
    @api ||= Api.yahoo
    @api.id
  end

  def intraday(sym, type = 'sma', days = 15)
    return [] if days == 0
    sym = Sym.find_by(name: sym) unless sym.is_a? Sym
    csv(sym, type, days).each_line.map do |line|
      next if line[0] != '1'
      tick = line.split(',')
      time = transform_time(tick[0])
      amount = transform_sma(tick[1])
      Tick.new(sym_id: sym.id, time: time, amount: amount)
    end.compact
  end

  def log_intraday_history(sym, type = 'sma')
    range = number_of_days_to_back_fill(sym)
    binding.pry
    return if range == 0
    data = intraday(sym, type, range)
    Tick.import(data)
    if data.any?
      sym.update_columns(
        last_updated_tick_time: data.last.time,
        volatility: sym.calculate_volatility,
        intraday_api_id: id,
        current_price: data.last.amount
        # LOG HISTORICAL EOD
      )
      print 'Success'
    else
      # It may have just been empty!!
      sym.update_column(:intraday_log_error, true)
    end
  end

  def historical_data(sym)
    begin
      CSV.parse open("http://ichart.finance.yahoo.com/table.csv?s=#{sym}&d=3&e=23&f=2010&g=d&a=3&b=12&c=1996&ignore=.csv").read
    rescue => error
      error
    end
  end

  def log_historical(sym)
    data = historical_data(sym)
    return data if not_successful?(data)
    if data.try(:each)
      historical_data = data.map.each_with_index do |line, i|
        next if i == 0
        sym.historical_datums.build(date: line[0], opening_price: line[1], closing_price: line[4])
      end.compact
      HistoricalDatum.import(historical_data)
      print 'Success'
      sym.update_columns(historical_data_logged: true, historical_api_id: api.id)
    else
      puts 'Incorrect format'
    end
  end

  def prices(symbols)
    # prices = open("http://finance.yahoo.com/d/quotes.csv?s=#{symbols.join('+')}&f=snl1").read
    prices = open("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in(#{ symbols.map{ |symbol| "%22#{symbol}%22" }.join('%2C')})&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=").read
    JSON.parse(prices)['query']['results']['quote'].map { |quote| { ask: quote['Bid'], symbol: quote['Symbol'] }}
  end

  def csv(sym, type, days)
    open("http://chartapi.finance.yahoo.com/instrument/1.0/#{sym.name}/chartdata;type=#{type};range=#{days}d/csv").read
  end

  def transform_time(unix_seconds)
    Time.at(unix_seconds.to_i).to_datetime
  end

  def transform_sma(sma)
    sma.strip
  end

  def number_of_days_to_back_fill(sym)
    today = Date.today
    last_tick_date = (sym.ticks.maximum(:time) || time - 15.days).to_date
    last_tick_date.to_date.business_days_until(today)
  end

  def day_not_finished?(time)
    # Needs TLC
    time.to_date == Time.now.in_time_zone('Eastern Time (US & Canada)').to_date
  end

  def not_successful?(error)
    true if error.is_a? StandardError
  end

  def handle_error(error, sym)
    print error.message
    if error.is_a? OpenURI::HTTPError
      sym.update_attribute(:historical_data_logged, false)
      return false
    end
    true
  end

end

