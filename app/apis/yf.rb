class Yf
  require 'open-uri'

  def new
    @api = Api.yahoo
  end

  def id
    @api ||= Api.yahoo
    @api.id
  end

  def log_intraday_history(sym)
    days = (Date.today - sym.last_tick_logged.time.to_date).to_i
    return print 'Already up to date!' if days == 0
    days = [days, 15].min # api won't allow for more than 15 days
    data = intraday_data(sym, days)
    if data.any?
      ticks = data.flat_map(&:ticks)
      new_ticks = ticks.reject(&:id)
      new_ticks.each { |tick| tick.day_id = tick.day.id } # update ticks' day_id
      Tick.import(new_ticks)
      starting_date = Date.today - days.days
      log_historical(sym, starting_date)
      sym.update_columns(
        volatility: sym.calculate_volatility,
        current_price: ticks.max_by(&:time).try(:price) || sym.current_price # if there are no ticks, it keeps the current price
      )
      print "Imported #{new_ticks.size.to_s.rjust(4, ' ')} ticks (#{data.size} days)"
      true
    else
      print 'No Ticks to import'
      false
    end
  end

  def intraday_data(sym, days)
    csv_data = csv_data(sym, days)
    csv_data.map do |day, tick_data|
      day = Day.find_or_create_by(date: day, sym_id: sym.id)
      existing_ticks_times = day.ticks.pluck(:time)
      tick_data.each do |(time, amount)|
        next if existing_ticks_times.include? time # avoid adding the same tick twice
        day.ticks.build(time: time, amount: amount)
      end
      day.add_endpoints
      day
    end
  end

  def historical_data(sym, start_date)
    begin
      # start date offset by one month because api reads january as 00 instead of 01
      start_date_params = (start_date - 1.month).strftime('a=%m&b=%d&c=%Y')
      CSV.parse open("http://ichart.finance.yahoo.com/table.csv?s=#{sym}&#{start_date_params}&ignore=.csv").read
    rescue => error
      print "Could not retrieve open/close prices for #{sym.padded}: #{error}"
    end
  end

  def log_historical(sym, start_date = '1 Jan 1900'.to_date)
    data = historical_data(sym, start_date)
    return data if not_successful?(data)
    existing_historical_data_days = HistoricalDatum.where(sym: sym).where('date > ?', start_date).pluck(:date)
    if data.try(:each)
      data.shift # skip header
      historical_data = data.map do |line|
        date = line[0].to_date
        next if date < start_date
        next if date.in?(existing_historical_data_days) # avoid logging same day multiple times
        sym.historical_datums.build(date: line[0], opening_price: line[1], closing_price: line[4])
      end.compact
      HistoricalDatum.import(historical_data)
    end
  end

  def prices(symbols)
    # prices = open("http://finance.yahoo.com/d/quotes.csv?s=#{symbols.join('+')}&f=snl1").read
    prices = open("https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.quotes%20where%20symbol%20in(#{ symbols.map{ |symbol| "%22#{symbol}%22" }.join('%2C')})&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=").read
    JSON.parse(prices)['query']['results']['quote'].map { |quote| { ask: quote['Bid'], symbol: quote['Symbol'] }}
  end

  def csv_data(sym, days)
    csv = open("http://chartapi.finance.yahoo.com/instrument/1.0/#{sym.name}/chartdata;type=sma;range=#{days}d/csv").read

    # remove unnecessary info and format into array
    raw_data = csv.each_line.map do |line|
      next if line[0] != '1'
      line.strip.split(',')
    end.compact

    # group by day and transform unix time into ruby timestamp
    data_grouped_by_day = {}
    raw_data.map do |(time, amount)|
      time = Time.at(time.to_i).to_datetime
      day = time.to_date
      data_grouped_by_day[day] ||= []
      data_grouped_by_day[day] << [time, amount]
    end
    data_grouped_by_day
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
