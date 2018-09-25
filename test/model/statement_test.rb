require 'test_helper'

class StatementTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      ENV.fetch('FINGERPRINT'),
      development_mode: true
    } 
  end


  def test_get_statement_by_user
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5a271c2592571b0034c0d9d8')
    response = SynapsePayRest::Statement.by_user(client: client, user: user)

    refute_nil response[1].pdf_url
    refute_nil response[1].csv_url
    refute_nil response[1].json_url
  end

  def test_get_statement_by_node
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5a271c2592571b0034c0d9d8')
    node = user.find_node(id: '5a399beece31670034632427')
    response = SynapsePayRest::Statement.by_node(client: client, node: node)

    refute_nil response[1].csv_url
    refute_nil response[1].pdf_url
    refute_nil response[1].json_url
  end

end
