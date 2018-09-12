require 'test_helper'

class ClientTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    }
  end

  def test_configured_through_options
    client = SynapsePayRest::Client.new(@options)
    # these keys don't exist in config
    @options.delete(:development_mode)
    @options[:oauth_key] = ''
    assert_equal client.client.config, @options
    assert_equal client.client.config, @options
    assert_equal client.client.base_url, 'https://uat-api.synapsefi.com/v3.1'
  end

  def test_endpoint_changes_when_development_mode_false
    @options[:development_mode] = false
    client = SynapsePayRest::Client.new(@options)
    assert_equal client.client.base_url, 'https://api.synapsefi.com/v3.1'
  end

  def test_instance_reader_methods
    client = SynapsePayRest::Client.new(@options)
    assert_instance_of SynapsePayRest::HTTPClient, client.client
    assert_instance_of SynapsePayRest::Users, client.users
    assert_instance_of SynapsePayRest::Nodes, client.nodes
    assert_instance_of SynapsePayRest::Transactions, client.transactions
    assert_instance_of SynapsePayRest::Subscriptions, client.subscriptions
    assert_instance_of SynapsePayRest::Institutions, client.institutions
    # deprecated
    assert_instance_of SynapsePayRest::Transactions, client.trans
  end

  # @todo turn on response logging as well as requests
  def test_logging_flags
    client = SynapsePayRest::Client.new(@options)
    assert_silent { client.users.create(payload: test_users_create_payload) }

    @options[:logging] = true
    client = SynapsePayRest::Client.new(@options)
    assert_output { client.users.create(payload: test_users_create_payload) }

    log_file = fixture_path('test.txt')
    @options[:log_to] = log_file
    client = SynapsePayRest::Client.new(@options)
    assert_output { client.users.create(payload: test_users_create_payload) }

    # cleanup
    File.delete(log_file)
  end

  def test_issue_public_key
    client = SynapsePayRest::Client.new(@options)
    response = client.issue_public_key(scope: 'CLIENT|CONTROLS')

    assert_equal ['CLIENT|CONTROLS'], response.scope
    refute_nil response.public_key
  end

  def test_crypto_quote
    client = SynapsePayRest::Client.new(@options)
    response = client.get_crypto_quotes

    refute_nil response.btcusd
  end
end
