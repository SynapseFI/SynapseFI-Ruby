require 'test_helper'

class ClientTest < Minitest::Test
  def test_configured_through_options
    options = {
        'fingerprint' => ENV.fetch('FINGERPRINT'),
        'client_id' => ENV.fetch('CLIENT_ID'),
        'client_secret' => ENV.fetch('CLIENT_SECRET'),
        'ip_address' => ENV.fetch('IP_ADDRESS'),
        'development_mode' => true
    }

    client = SynapsePayRest::Client.new(options: options)
    assert_equal client.client.config, options
    assert_equal client.client.base_url, 'https://sandbox.synapsepay.com/api/3'
  end

  def test_endpoint_changes_when_development_mode_false
    options = {
        'fingerprint' => ENV.fetch('FINGERPRINT'),
        'client_id' => ENV.fetch('CLIENT_ID'),
        'client_secret' => ENV.fetch('CLIENT_SECRET'),
        'ip_address' => ENV.fetch('IP_ADDRESS'),
        'development_mode' => false
    }

    client = SynapsePayRest::Client.new(options: options)
    assert_equal client.client.config, options
    assert_equal client.client.base_url, 'https://synapsepay.com/api/3'
  end
end
