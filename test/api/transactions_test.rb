require 'test_helper'

class TransactionsTest < Minitest::Test
  def setup
    @client = test_client_with_two_transactions
    @nodes  = @client.nodes.get['nodes']
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
      node_id: @nodes.first['_id'],
      payload: transaction_payload
    )

    refute_nil transaction_response['_id']
    assert_equal transaction_response['amount']['amount'], transaction_payload['amount']['amount']
    assert_equal transaction_response['amount']['currency'], transaction_payload['amount']['currency']
    assert_equal transaction_response['to']['id'], transaction_payload['to']['id']
  end

  def test_transactions_get
    transactions_response = @client.trans.get(node_id: @nodes.first['_id'])

    assert transactions_response['error_code'], 0
    assert transactions_response['http_code'], 200
    assert_operator transactions_response['trans_count'], :>, 0
  end

  def test_transactions_get_with_transaction_id
    transactions_response = @client.trans.get(node_id: @nodes.first['_id'])
    transaction_id = transactions_response['trans'].first['_id']
    transaction_response = @client.trans.get(
      node_id: @nodes.first['_id'],
      trans_id: transaction_id
    )

    assert_equal transaction_response['_id'], transaction_id
  end

  def test_transactions_update
    payload = {'comment' => 'I am comment'}
    transactions_response = @client.trans.get(node_id: @nodes.first['_id'])
    transaction_id = transactions_response['trans'].first['_id']
    update_response = @client.trans.update(
      node_id: @nodes.first['_id'],
      trans_id: transaction_id,
      payload: payload
    )
    note = update_response['trans']['recent_status']['note']

    assert_equal update_response['http_code'], '200'
    assert_equal update_response['error_code'], '0'
    assert_match /I am comment/, note
  end

  def test_transactions_delete
    client = test_client_with_two_nodes
    nodes  = client.nodes.get['nodes']

    transaction_payload = {
      'to' => {
        'type' => 'ACH-US',
        'id'   => nodes.first['_id']
      },
      'amount' => {
        'amount'   => 22,
        'currency' => 'USD'
      },
      'extra' => {
        'ip' => '192.168.0.1'
      }
    }

    trans_create_response = client.trans.create(node_id: nodes.first['_id'], payload: transaction_payload)
    transactions = client.trans.get(node_id: nodes.first['_id'])['trans']
    delete_response = client.trans.delete(
      node_id: nodes.first['_id'],
      trans_id: transactions.first['_id']
    )
    status = delete_response['recent_status']['status']

    assert_equal 'CANCELED', status
  end
end
