require 'test_helper'

class ClientTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('CLIENT_ID'),
      client_secret:    ENV.fetch('CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    }
  end

  def test_configured_through_options
    client = SynapsePayRest::Client.new(@options)
    assert_equal client.client.config, @options
    assert_equal client.client.base_url, 'https://sandbox.synapsepay.com/api/3'
  end

  def test_endpoint_changes_when_development_mode_false
    @options['development_mode'] = false
    client = SynapsePayRest::Client.new(@options)
    assert_equal client.client.config, @options
    assert_equal client.client.base_url, 'https://synapsepay.com/api/3'
  end

  def test_instance_reader_methods
    client = SynapsePayRest::Client.new(@options)
    assert_instance_of SynapsePayRest::HTTPClient, client.client
    assert_instance_of SynapsePayRest::Users, client.users
    assert_instance_of SynapsePayRest::Nodes, client.nodes
    assert_instance_of SynapsePayRest::Transactions, client.transactions
    # deprecated
    assert_instance_of SynapsePayRest::Transactions, client.trans
  end

  # TODO: turn on response logging as well as requests
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
end
