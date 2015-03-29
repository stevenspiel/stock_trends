class N
  # Register for more access

  def new
    @api = Api.nasdaq
  end

  def quotes_by_price(high, low, *symbols)
    url = 'http://ws.nasdaqdod.com/v1/NASDAQQuotes.asmx?WSDL'

    soap_header = {
      'Header' => {
        '@xmlns' => 'http://www.xignite.com/services/',
        'Username' => 'C3982EE77BF3416BA863016FD72913E6'
      }
    }

    client = Savon.client(wsdl: url, :soap_header => soap_header, convert_request_keys_to: :none, env_namespace: 'soap')

    response = client.call(:search_quotes_by_bid_ask_price, message: {
        '@xmlns' => 'http://www.xignite.com/services/',
        Symbols: symbols.join(', '),
        StartDateTime: '3/23/2015 09:30:00.000',
        EndDateTime: '3/23/2015 09:30:25.000',
        MarketCenters: 'Q, B',
        LowPrice: low,
        HighPrice: high,
        Side: 'Bid'
      })

    response.to_hash
  end

  def formatted_time(datetime)
    datetime.strftime('%m')
    # 3/23/2015 09:30:00.000
  end
end
