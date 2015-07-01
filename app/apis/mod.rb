class Mod
  require 'open-uri'
  require 'net/http'

  def new
    @api = Api.market_on_demand
  end

  # def initialize(normalized: false, number_of_days: 1, data_period: 'Minute', start_date: nil, end_date: nil, data_interval: 5, symbol: nil, type: 'price', params: 'sma')
  def initialize(normalized: nil, number_of_days: nil, data_period: nil, start_date: nil, end_date: nil, data_interval: nil, symbol: nil, type: 'price', params: ['sma'])
    @normalized = normalized
    @number_of_days = number_of_days
    @data_period = data_period
    @start_date = start_date
    @end_date = end_date
    @data_interval = data_interval
    @symbol = symbol.to_s
    @type = type.to_s
    @params = params
  end

  def request
    open("http://dev.markitondemand.com/Api/v2/InteractiveChart/json?parameters=#{parameterize(parameters)}").read
  end

  def current_prices(*symbols)
    symbols.map do |symbol|
      JSON.parse(open("http://dev.markitondemand.com/Api/v2/Quote/json?Symbol=#{symbol}").read)['LastPrice']
    end
  end

  def parameters
    {
      'Normalized' => @normalized,
      'NumberOfDays' => @number_of_days,
      'DataPeriod' => @data_period,
      'StartDate' => formatted_date(@start_date),
      'EndDate' => formatted_date(@end_date),
      'Elements' => elements
    }.reject{|_,v| v == '' || v == nil}
  end

  def elements
    [
      {
        'Symbol' => @symbol,
        'Type' => @type,
        'Params' => @params
      }.reject{|_,v| v == '' || v == nil}
    ].reject(&:blank?)
  end

  def deparameterize(url)
    subs = {
      '%2f' => '/',
      '_'   => ' ',
      '%7B' => '{',
      '%7D' => '}',
      '%5B' => '[',
      '%5D' => ']',
      '%22' => '"',
      '%3A' => ':',
      '%2C' => ',',
    }
    subs.each do |param, deparam|
      url.gsub!(param, deparam)
    end
    url
  end

  def parameterize(params)
    subs = {
      ' ' => '',
      '/' => '%2f',
      '{' => '%7B',
      '}' => '%7D',
      '[' => '%5B',
      ']' => '%5D',
      '"' => '%22',
      '=>' => ':',
      ':' => '%3A',
      ',' => '%2C',
    }
    params = params.to_s
    puts params
    subs.each do |param, deparam|
      params.gsub!(param, deparam)
    end
    params
  end

  def formatted_date(datetime)
    return unless datetime.present?
    datetime.strftime('%Y-%m-%dT%H:%M:%S:00')
    # 2011-03-01T00:00:00-00
  end
end
