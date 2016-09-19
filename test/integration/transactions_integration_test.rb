require 'test_helper'

class TransactionsIntegrationTest < Minitest::Test
  def setup
    # @client = client_with_user
    @client = client_with_node
    @user = oauth_user(@client, ENV.fetch('USER_ID'))
    @from_node = @client.nodes.get['nodes'].first
    @to_node = @client.nodes.get['nodes'].last
  end

  # ##############
  # base API calls
  # ##############
  
  def test_transactions_create
    transaction_payload = {
      'to':{
        'type': 'ACH-US',
        'id': @to_node['_id']
      },
      'amount': {
        'amount': 1000,
        'currency': 'USD'
        },
        'extra': {
          'ip': '192.168.0.1'
        }
      }
    transaction_response = @client.trans.create(node_id: @from_node['_id'], payload: transaction_payload)

    refute_nil transaction_response['_id']
  end

  def test_transactions_get
    transactions_response = @client.trans.get(node_id: @from_node['_id'])

    assert transactions_response['error_code'], 0
    assert transactions_response['http_code'], 200
    assert_operator transactions_response['trans_count'], :>, 0
  end

  def test_transactions_get_with_transaction_id
    transactions_response = @client.trans.get(node_id: @from_node['_id'])
    transaction_id = transactions_response['trans'].first['_id']
    transaction_response = @client.trans.get(node_id: @from_node['_id'], trans_id: transaction_id)

    assert_equal transaction_response['_id'], @from_node['_id']
  end

  def test_transactions_update
    payload = {'comment' =>  'I am comment'}
    transactions_response = @client.trans.get(node_id: @from_node['_id'])
    transaction_id = transactions_response['trans'].first['_id']
    update_response = @client.trans.update(node_id: @from_node['_id'], trans_id: transaction_id, payload: payload)
    note = update_response['trans']['recent_status']['note']

    assert_equal update_response['http_code'], '200'
    assert_equal update_response['error_code'], '0'
    assert_match /I am comment/, note
  end

  def test_transactions_delete
    transaction_payload = {
      'to':{
        'type': 'ACH-US',
        'id': @to_node['_id']
      },
      'amount': {
        'amount': 1000,
        'currency': 'USD'
        },
        'extra': {
          'ip': '192.168.0.1'
        }
      }
    transaction_response = @client.trans.create(node_id: @from_node['_id'], payload: transaction_payload)
    transaction_id = transaction_response['_id']
    delete_response = @client.trans.delete(node_id: @from_node['_id'], trans_id: transaction_id)
    status = delete_response['recent_status']['status']
    
    assert status, 'CANCELED'
  end
end
