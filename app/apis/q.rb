class Q
  require 'open-uri'
  require 'net/http'

  def new
    @api = Api.quandl
  end

  def initialize
    @auth_token = YAML.load_file(Rails.root.join('config', 'keys.yml'))['quandl_auth_token']
  end

  def log_historical(sym)
    data = historical_data(sym)
    return data unless data.respond_to?(:readlines)
    build_and_save_data(sym, data)
    print 'Success'
    sym.update_columns(historical_data_logged: true)
  end

  def build_and_save_data(sym, data)
    historical_data = data.map.each_with_index do |line, i|
      next if i == 0
      line = line.split(',')
      sym.historical_datums.build(date: line[0], opening_price: line[1], closing_price: line[4])
    end.compact
    HistoricalDatum.import(historical_data)
  end

  def historical_data(symbol)
    begin
      open("https://www.quandl.com/api/v1/datasets/WIKI/#{symbol.name}.csv?auth_token=#{@auth_token}")
    rescue => error
      error
    end
    # https://www.quandl.com/api/v1/datasets/WIKI/ADT.csv?auth_token=
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
