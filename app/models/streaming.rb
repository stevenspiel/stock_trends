class Streaming
  require 'em-http'
  require 'em-http/middleware/oauth'

  def self.run(*symbols)
    EM.run do
      options = {
       inactivity_timeout: 25_000
      }

      conn = EventMachine::HttpRequest.new("https://stream.tradeking.com/v1/market/quotes.json?symbols=#{symbols.join(',')}", options)
      conn.use EventMachine::Middleware::OAuth, Credentials.keys

      http = conn.get
      http.stream { |chunk| puts chunk }

      http.errback do
        EM.stop
      end

      trap('INT')  { http.close; EM.stop }
      trap('TERM') { http.close; EM.stop }
    end
  end
end
