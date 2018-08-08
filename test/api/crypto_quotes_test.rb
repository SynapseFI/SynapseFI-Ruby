require 'test_helper'

class Crypto_QuotesTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    }
    @user = test_user
  end

  def test_crypto_quote_get
    client = SynapsePayRest::Client.new(@options)

    crypto_quotes_response = client.crypto_quotes.get()
    refute_nil crypto_quotes_response["BTCUSD"]
  end

end
