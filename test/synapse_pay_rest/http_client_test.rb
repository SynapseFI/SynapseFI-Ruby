require 'test_helper'

class HTTPClientTest < Minitest::Test
  def setup
    @client = test_client
    @http_client = @client.http_client
  end

  def teardown
    RestClient.proxy = nil
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
    assert_equal headers['X-SP-GATEWAY'], "#{config[:client_id]}|#{config[:client_secret]}"
    # oauth_key|fingerprint
    assert_equal headers['X-SP-USER'], "#{config[:oauth_key]}|#{config[:fingerprint]}"
    assert_equal headers['X-SP-USER-IP'], config[:ip_address]
  end

  def test_update_headers
    new_options = {
      fingerprint:   'new fingerprint',
      client_id:     'new client_id',
      client_secret: 'new client_secret',
      ip_address:    'new ip',
      oauth_key:     'new oauth_key'
    }
    @http_client.update_headers(new_options)
    config = @http_client.config

    assert_equal config[:fingerprint], new_options[:fingerprint]
    assert_equal config[:client_id], new_options[:client_id]
    assert_equal config[:client_secret], new_options[:client_secret]
    assert_equal config[:ip_address], new_options[:ip_address]
    assert_equal config[:oauth_key], new_options[:oauth_key]
  end

  def test_proxy_url
    proxy_url = 'http://proxy.example.org:80'

    client_without_proxy = test_client
    assert_nil client_without_proxy.http_client.proxy_url
    assert_nil RestClient.proxy

    client_with_proxy = test_client(proxy_url: proxy_url)
    assert_equal client_with_proxy.http_client.proxy_url, proxy_url
    assert_equal RestClient.proxy, proxy_url
  end
end
