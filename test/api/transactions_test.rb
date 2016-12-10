require 'test_helper'

class TransactionsTest < Minitest::Test
  def setup
    test_values   = test_client_with_two_transactions
    @client       = test_values[:client]
    @user         = test_values[:user]
    @nodes        = test_values[:nodes]
    @transactions = test_values[:transactions]
  end

  def test_transactions_create
    transaction_payload = {
      'to' => {
        'type' => 'SYNAPSE-US',
        'id'   => @nodes.last['_id']
      },
      'amount' => {
        'amount'   => 55,
        'currency' => 'USD'
      },
      'extra' => {
        'ip' => '192.168.0.1'
      }
    }
    transaction_response = @client.trans.create(
      user_id: @user['_id'],
      node_id: @nodes.first['_id'],
      payload: transaction_payload
    )

    refute_nil transaction_response['_id']
    assert_equal transaction_response['amount']['amount'], transaction_payload['amount']['amount']
    assert_equal transaction_response['amount']['currency'], transaction_payload['amount']['currency']
    assert_equal transaction_response['to']['id'], transaction_payload['to']['id']
  end

  def test_transactions_get
    transactions_response = @client.trans.get(
      user_id: @user['_id'],
      node_id: @nodes.first['_id']
    )

    assert transactions_response['error_code'], 0
    assert transactions_response['http_code'], 200
    assert_operator transactions_response['trans_count'], :>, 0
  end

  def test_transactions_get_with_transaction_id
    transactions_response = @client.trans.get(
      user_id: @user['_id'],
      node_id: @nodes.first['_id']
    )
    transaction_id = transactions_response['trans'].first['_id']
    transaction_response = @client.trans.get(
      user_id: @user['_id'],
      node_id: @nodes.first['_id'],
      trans_id: transaction_id
    )

    assert_equal transaction_response['_id'], transaction_id
  end

  def test_transactions_update
    payload = {'comment' => 'Show me what you got'}
    
    update_response = @client.trans.update(
      user_id: @user['_id'],
      node_id: @nodes.first['_id'],
      trans_id: @transactions.first['_id'],
      payload: payload
    )
    note = update_response['trans']['recent_status']['note']

    assert_equal update_response['http_code'], '200'
    assert_equal update_response['error_code'], '0'
    assert_match /Show me what you got/, note
  end

  def test_transactions_delete
    transaction_payload = {
      'to' => {
        'type' => 'ACH-US',
        'id'   => @nodes.first['_id']
      },
      'amount' => {
        'amount'   => 22,
        'currency' => 'USD'
      },
      'extra' => {
        'ip' => '192.168.0.1'
      }
    }

    delete_response = @client.trans.delete(
      user_id: @user['_id'],
      node_id: @nodes.first['_id'],
      trans_id: @transactions.first['_id']
    )
    status = delete_response['recent_status']['status']

    assert_equal 'CANCELED', status
  end
end
