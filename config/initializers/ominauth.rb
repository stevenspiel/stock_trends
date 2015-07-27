OmniAuth.config.logger = Rails.logger

CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'keys.yml'))

module Google
  CLIENT_ID = CONFIG['google_client_id']
  CLIENT_SECRET = CONFIG['google_client_secret']
  KEY = CONFIG['google_key']
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :google_oauth2,
    Google::CLIENT_ID,
    Google::CLIENT_SECRET,
    {
      client_options: {
        ssl: {
          ca_file: Rails.root.join('cacert.pem').to_s
        }
      }
    }
  )
end
