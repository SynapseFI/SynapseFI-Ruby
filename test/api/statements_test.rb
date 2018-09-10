require 'test_helper'

class StatementsTest < Minitest::Test
  def setup
     @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID_STATEMENTS'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET_STATEMENTS'),
      ip_address:       '127.0.0.1',
      fingerprint:      'ed234f9a5dcaf00f9e231a7079ac9961',
      development_mode: true
    } 
    @client = SynapsePayRest::Client.new(@options)
  end

  def test_statements_get
  	user = SynapsePayRest::User.find(client: @client, id: '5b5f95dcf122e319740dbc76')
    statements_response = @client.statements.get(user_id: user.id)
    assert_equal '0', statements_response['error_code']
    assert_equal '200', statements_response['http_code']
  end

end
