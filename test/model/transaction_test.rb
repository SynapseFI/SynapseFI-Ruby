require 'test_helper'

class TransactionTest < Minitest::Test
  def setup
    @user = test_user_with_two_nodes
  end

  def test_create
    from_node = @user.nodes.first
    to_node   = @user.nodes.last

    refute_equal from_node.id, to_node.id

    args = {
      node: from_node,
      to_type: 'SYNAPSE-US',
      to_id: to_node.id,
      amount: 1.10,
      currency: 'USD',
      supp_id: '1283764wqwsdd34wd13212',
      note: 'Deposit to bank account',
      process_on: 1,
      ip: '192.168.0.1',
      fee_amount: 1.00,
      fee_note: 'Facilitator Fee',
      fee_to_id: to_node.id
    }
    transaction = SynapsePayRest::Transaction.create(args)

    # TODO: whatever instance variables should populate from response
    other_instance_vars = []

    assert_instance_of SynapsePayRest::Transaction, transaction.from_node
    assert_instance_of SynapsePayRest::Transaction, transaction.to_node
    assert_equal from_node, transaction.from_node
    assert_equal to_node, transaction.to_node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      assert_equal value, transaction.send(var_name)
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_with_insufficient_funds
    skip 'pending'
  end

  # TODO: notify if node not verified
  def test_create_with_insufficient_permissions
    skip 'pending'
  end

  def test_ach_returns
    skip 'pending'
  end
end
