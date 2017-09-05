require 'test_helper'

class NodesTest < Minitest::Test
  def setup
    test_values = test_client_with_user
    @client = test_values[:client]
    @user   = test_values[:user]
  end

  def test_nodes_add_with_bank_login_no_mfa
    response = @client.nodes.add(
      user_id: @user['_id'],
      payload: test_ach_us_login_no_mfa_payload
    )

    assert_equal response['http_code'], '200'
    assert_equal response['error_code'], '0'
    assert_operator response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_bank_login_and_verify_mfa_questions
    add_response = @client.nodes.add(
      user_id: @user['_id'],
      payload: test_ach_us_login_with_mfa_payload
    )

    assert_equal add_response['http_code'], '202'
    assert_equal add_response['error_code'], '10'
    refute_nil add_response['mfa']

    access_token = add_response['mfa']['access_token']
    mfa_response = @client.nodes.verify(
      user_id: @user['_id'],
      payload: test_mfa_payload(access_token: access_token)
    )

    assert_equal mfa_response['http_code'], '200'
    assert_equal mfa_response['error_code'], '0'
    assert_operator mfa_response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_account_and_routing_and_verify_with_correct_microdeposits
    add_response = @client.nodes.add(
      user_id: @user['_id'],
      payload: test_ach_us_manual_payload
    )

    assert_equal add_response['http_code'], '200'
    assert_equal add_response['error_code'], '0'

    node_id = add_response['nodes'][0]['_id']
    
    resend_micro_response = @client.nodes.resend_micro(
      user_id: @user['_id'],
      node_id: node_id
    )
    
    refute_nil resend_micro_response['_id']
    
    microdeposit_response = @client.nodes.verify(
      user_id: @user['_id'],
      node_id: node_id,
      payload: test_microdeposit_payload
    )

    refute_nil microdeposit_response['_id']
  end

  def test_nodes_get
    test_values = test_client_with_node
    client = test_values[:client]
    user = test_values[:user]
    response = client.nodes.get(user_id: user['_id'])

    assert_equal response['http_code'], '200'
    assert_equal response['error_code'], '0'
    assert_operator response['nodes'].length, :>, 0
    assert_operator response['node_count'], :>, 0
  end

  def test_nodes_get_with_node_id
    test_values    = test_client_with_node
    client         = test_values[:client]
    user           = test_values[:user]
    nodes_response = client.nodes.get(user_id: user['_id'])
    node_id        = nodes_response['nodes'].first['_id']
    node_response  = client.nodes.get(user_id: user['_id'], node_id: node_id)

    assert_equal node_response['_id'], node_id
    assert_nil node_response['error']
  end

  def test_nodes_delete
    test_values     = test_client_with_node
    client          = test_values[:client]
    user            = test_values[:user]
    nodes_response  = client.nodes.get(user_id: user['_id'])
    node_id         = nodes_response['nodes'].first['_id']
    delete_response = client.nodes.delete(user_id: user['_id'], node_id: node_id)

    refute delete_response['is_active']
  end
end
