require 'test_helper'

class NodesTest < Minitest::Test
  def setup
    @client = test_client_with_user
    @user = oauth_user(@client, @client.user_id)
  end

  def test_nodes_add_with_bank_login_no_kba
    payload = {
      'type' => 'ACH-US',
      'info' => {
        'bank_id' => 'synapse_nomfa',
        'bank_pw' => 'test1234',
        'bank_name' => 'fake'
      }
    }
    response = @client.nodes.add(payload: payload)

    assert_equal response['http_code'], '200'
    assert_equal response['error_code'], '0'
    assert_operator response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_bank_login_and_verify_mfa_questions
    add_payload = {
      'type' => 'ACH-US',
      'info' => {
        'bank_id' => 'synapse_good',
        'bank_pw' => 'test1234',
        'bank_name' => 'fake'
      }
    }
    add_response = @client.nodes.add(payload: add_payload)

    assert_equal add_response['http_code'], '202'
    assert_equal add_response['error_code'], '10'
    refute_nil add_response['mfa']

    mfa_payload = {
      'access_token' => add_response['mfa']['access_token'],
      'mfa_answer' => 'test_answer'
    }
    mfa_response = @client.nodes.verify(payload: mfa_payload)
    
    assert_equal mfa_response['http_code'], '200'
    assert_equal mfa_response['error_code'], '0'
    assert_operator mfa_response['nodes'].length, :>, 0
  end

  def test_nodes_add_with_account_and_routing_and_verify_microdeposits
    add_payload = {
      'type' => 'ACH-US',
      'info' => {
        'nickname' => 'Ruby Library Savings Account',
        'name_on_account' => 'Ruby Library',
        'account_num' => '72347235423',
        'routing_num' => '051000017',
        'type' => 'PERSONAL',
        'class' => 'CHECKING'
      },
      'extra' => {
        'supp_id' => '123sa'
      }
    }
    add_response = @client.nodes.add(payload: add_payload)

    assert_equal add_response['http_code'], '200'
    assert_equal add_response['error_code'], '0'

    microdeposit_payload = {'micro' => [0.1, 0.1]}
    node_id = add_response['nodes'][0]['_id']
    microdeposit_response = @client.nodes.verify(
      node_id: node_id,
      payload: microdeposit_payload
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

    verify_deleted_response = client.nodes.get(node_id: node_id)

    assert_nil verify_deleted_response['_id']
    refute verify_deleted_response['success']
  end
end
