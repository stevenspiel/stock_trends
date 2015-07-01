class Tk
  def initialize
    @keys = Credentials.keys
    @consumer = OAuth::Consumer.new @keys[:consumer_key], @keys[:consumer_secret], { site: 'https://api.tradeking.com' }
    @access_token = OAuth::AccessToken.new(@consumer, @keys[:access_token], @keys[:access_token_secret])
    @api = Api.trade_king
  end

  def accounts
    @access_token.get('/v1/accounts.json', { 'Accept' => 'application/json' })
  end

  def get(url)
    @access_token.get("/v1/#{url}.json", { 'Accept' => 'application/json' })
  end

  def quote(symbols = [], fields = [])
    @access_token.get("#{base}/market/ext/quotes.json#{symbols(symbols)}#{fields(fields)}")
  end

  def prices(symbols = [])
    json = @access_token.get("#{base}/market/ext/quotes.json#{symbols(symbols)}#{fields(['ask'])}").body
    JSON.parse(json)['response']['quotes']['quote'].map{ |quote| { ask: quote['ask'], symbol: quote['symbol'] } }
  end

  def custom(url)
    @access_token.get(url)
  end

  private

  def base
    'https://api.tradeking.com/v1'
  end

  def symbols(symbols)
    "?symbols=#{symbols.join(',')}" if symbols.any?
  end

  def fields(fields)
    "&fids=#{fields.join(',')}" if fields.any?
  end

end
