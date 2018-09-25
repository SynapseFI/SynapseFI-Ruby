require 'test_helper'

class StatementsTest < Minitest::Test
  def setup
     @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      ENV.fetch('FINGERPRINT'),
      development_mode: true
    } 
    @client = SynapsePayRest::Client.new(@options)
  end

  def test_statements_get
  	user = SynapsePayRest::User.find(client: @client, id: '5a271c2592571b0034c0d9d8')
    statements_response = @client.statements.get(user_id: user.id)
    assert_equal '0', statements_response['error_code']
    assert_equal '200', statements_response['http_code']
  end

end
