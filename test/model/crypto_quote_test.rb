require 'test_helper'

class CryptoQuoteTest < Minitest::Test
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

  def test_get_crypto_quote
    client = SynapsePayRest::Client.new(@options)
    crypto_quote = SynapsePayRest::CryptoQuote.get(client: client)
    
    assert_instance_of SynapsePayRest::CryptoQuote, crypto_quote

    other_instance_vars = [:client, :ethusd, :btcusd, :usdbtc, :usdeth]

    other_instance_vars.each { |var| refute_nil crypto_quote.send(var) }
  end
end
