require 'test_helper'

class PublicKeyTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    } 
  end


  def test_client_issue_public_key
  	client = SynapsePayRest::Client.new(@options)
    response = SynapsePayRest::PublicKey.issue(client: client, scope: 'CLIENT|CONTROLS')

    assert_equal ['CLIENT|CONTROLS'], response.scope
    refute_nil response.public_key
  end

end
