require 'test_helper'

class StatementTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID_STATEMENTS'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET_STATEMENTS'),
      ip_address:       '127.0.0.1',
      fingerprint:      'ed234f9a5dcaf00f9e231a7079ac9961',
      development_mode: true
    } 
  end


  def test_get_statement_by_user
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5b5f95dcf122e319740dbc76')
    response = SynapsePayRest::Statement.by_user(client: client, user: user)

    refute_nil response[1].pdf_url
    refute_nil response[1].csv_url
  end

  def test_get_statement_by_node
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5b5f95dcf122e319740dbc76')
    node = user.find_node(id: '5b634a241374e5004c7b39b1')
    response = SynapsePayRest::Statement.by_node(client: client, node: node)

    refute_nil response[1].csv_url
    refute_nil response[1].pdf_url
  end

end
