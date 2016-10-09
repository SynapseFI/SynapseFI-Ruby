require 'test_helper'

class NodesTest < Minitest::Test
  def setup
    @client = test_client_with_user
    @user   = refresh_user(@client, @client.client.user_id)
  end

  def test_nodes_add_with_bank_login_no_mfa
    response = @client.nodes.add(payload: test_ach_us_login_no_mfa_payload)

    assert_equal response['http_code'], '200'
    assert_equal response['error_code'], '0'
    assert_operator response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_bank_login_and_verify_mfa_questions
    add_response = @client.nodes.add(payload: test_ach_us_login_with_mfa_payload)

    assert_equal add_response['http_code'], '202'
    assert_equal add_response['error_code'], '10'
    refute_nil add_response['mfa']

    access_token = add_response['mfa']['access_token']
    mfa_response = @client.nodes.verify(payload: test_mfa_payload(access_token: access_token))

    assert_equal mfa_response['http_code'], '200'
    assert_equal mfa_response['error_code'], '0'
    assert_operator mfa_response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_account_and_routing_and_verify_with_correct_microdeposits
    add_response = @client.nodes.add(payload: test_ach_us_manual_payload)

    assert_equal add_response['http_code'], '200'
    assert_equal add_response['error_code'], '0'

    node_id = add_response['nodes'][0]['_id']
    microdeposit_response = @client.nodes.verify(
      node_id: node_id,
      payload: test_microdeposit_payload
    )

    refute_nil microdeposit_response['_id']
  end

  def test_nodes_get
    client = test_client_with_node
    response = client.nodes.get

    assert_equal response['http_code'], '200'
    assert_equal response['error_code'], '0'
    assert_operator response['nodes'].length, :>, 0
    assert_operator response['node_count'], :>, 0
  end

  def test_nodes_get_with_node_id
    client = test_client_with_node
    nodes_response = client.nodes.get
    node_id = nodes_response['nodes'].first['_id']
    node_response = client.nodes.get(node_id: node_id)

    assert_equal node_response['_id'], node_id
    assert_nil node_response['error']
  end

  def test_nodes_delete
    client = test_client_with_node
    nodes_response = client.nodes.get

    node_id = nodes_response['nodes'].first['_id']
    delete_response = client.nodes.delete(node_id: node_id)

    assert_equal delete_response['http_code'], '200'
    assert_equal delete_response['error_code'], '0'

    # verify node deleted
    assert_raises SynapsePayRest::Error::NotFound do
      client.nodes.get(node_id: node_id)
    end
  end
end
