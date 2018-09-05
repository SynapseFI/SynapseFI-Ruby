require 'test_helper'

class StatementTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    } 
  end


  def test_get_statement_by_user
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5b5f95dcf122e319740dbc76')
    response = SynapsePayRest::Statement.by_node(client: client, user: user)

    refute_nil response.pdf_url
    refute_nil response.csv_url
  end

  def test_get_statement_by_node
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5b5f95dcf122e319740dbc76')
    node = user.find_node(id: '5b634a241374e5004c7b39b1')
    response = SynapsePayRest::Statement.by_node(client: client, node: node)

    refute_nil response.csv_url
    refute_nil response.pdf_url
  end

end
