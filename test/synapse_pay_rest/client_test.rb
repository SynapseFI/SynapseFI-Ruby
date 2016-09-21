require 'test_helper'

class ClientTest < Minitest::Test
  def setup
    @options = {
      'client_id' => ENV.fetch('CLIENT_ID'),
      'client_secret' => ENV.fetch('CLIENT_SECRET'),
      'development_mode' => true
    }
  end

  def test_configured_through_options
    client = SynapsePayRest::Client.new(options: @options)
    assert_equal client.client.config, @options
    assert_equal client.client.base_url, 'https://sandbox.synapsepay.com/api/3'
  end

  def test_endpoint_changes_when_development_mode_false
    options = @options.dup
    options['development_mode'] = false
    client = SynapsePayRest::Client.new(options: options)
    assert_equal client.client.config, options
    assert_equal client.client.base_url, 'https://synapsepay.com/api/3'
  end

  def test_instance_reader_methods
    client = SynapsePayRest::Client.new(options: @options)
    assert_instance_of SynapsePayRest::HTTPClient, client.client
    assert_instance_of SynapsePayRest::Users, client.users
    assert_instance_of SynapsePayRest::Nodes, client.nodes
    assert_instance_of SynapsePayRest::Transactions, client.transactions
    # deprecated
    assert_instance_of SynapsePayRest::Transactions, client.trans
  end
end
