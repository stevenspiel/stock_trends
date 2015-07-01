class Credentials
  def initialize
    @keys = YAML.load_file(Rails.root.join('config', 'keys.yml'))
  end

  def self.keys
    new.keys
  end

  def keys
    {
      consumer_key: @keys['consumer_key'],
      consumer_secret: @keys['consumer_secret'],
      access_token: @keys['access_token'],
      access_token_secret: @keys['access_token_secret']
    }
  end
end
