require 'test_helper'

class HTTPClientTest < Minitest::Test
  def setup
    @client = test_client_with_user
    refresh_user(@client, @client.client.user_id)
    @http_client = @client.client
  end

  def test_base_url
    assert_respond_to @http_client, :base_url
  end

  def test_config_exists_and_returns_a_hash
    assert_instance_of Hash, @http_client.config
  end

  def test_get_headers
    headers = @http_client.get_headers
    config  = @http_client.config
    # client_id|client_secret
    assert_equal headers['X-SP-GATEWAY'], "#{config['client_id']}|#{config['client_secret']}"
    # oauth_key|fingerprint
    assert_equal headers['X-SP-USER'], "#{config['oauth_key']}|#{config['fingerprint']}"
    assert_equal headers['X-SP-USER-IP'], config['ip_address']
  end

  def test_update_headers
    new_options = {
      user_id:       'new user_id',
      fingerprint:   'new fingerprint',
      client_id:     'new client_id',
      client_secret: 'new client_secret',
      ip_address:    'new ip',
      oauth_key:     'new oauth_key'
    }
    @http_client.update_headers(new_options)
    config = @http_client.config

    assert_equal @http_client.user_id, new_options[:user_id]
    assert_equal config['fingerprint'], new_options[:fingerprint]
    assert_equal config['client_id'], new_options[:client_id]
    assert_equal config['client_secret'], new_options[:client_secret]
    assert_equal config['ip_address'], new_options[:ip_address]
    assert_equal config['oauth_key'], new_options[:oauth_key]
  end
end
