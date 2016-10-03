require 'test_helper'

class TransactionTest < Minitest::Test
  def setup
    @user = test_user_with_two_nodes
  end

  def test_create_with_fee
    from_node = @user.nodes.first
    to_node   = @user.nodes.last

    fee_node_args = test_synapse_us_create_args
    fee_node_args.delete(:user)
    fee_node = @user.create_synapse_us_node(fee_node_args)

    refute_equal from_node.id, to_node.id
    # need to add a type field
    args = test_transaction_create_args(
      node: from_node,
      to_type: to_node.type,
      to_id: to_node.id,
      fee_to_id: fee_node.id
    )
    transaction = SynapsePayRest::Transaction.create(args)

    # TODO: whatever instance variables should populate from response
    other_instance_vars = [
      :node, :amount, :currency, :client_id, :client_name, :created_on,
      :ip, :latlon, :note, :process_on, :supp_id, :webhook, :fees,
      :recent_status, :timeline, :from, :to, :to_type, :to_id
    ]

    assert_kind_of SynapsePayRest::BaseNode, transaction.node
    assert_equal from_node, transaction.node
    assert_equal to_node.id, transaction.to['id']
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      # this gets replaced by process_on
      next if var_name == :process_in
      if var_name == :process_on
        assert_operator transaction.send(var_name), :>, Time.new.to_i
      else
        assert_equal value, transaction.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil transaction.send(var) }
  end

  def test_create_without_fee
    from_node = @user.nodes.first
    to_node   = @user.nodes.last

    refute_equal from_node.id, to_node.id
    # need to add a type field
    args = test_transaction_create_args(
      node: from_node,
      to_type: to_node.type,
      to_id: to_node.id,
      fee_to_id: nil,
      fee_amount: nil,
      fee_note: nil
    )
    transaction = SynapsePayRest::Transaction.create(args)

    assert_kind_of SynapsePayRest::BaseNode, transaction.node
    assert_equal from_node, transaction.node
    assert_equal to_node.id, transaction.to['id']
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

  def test_find
  end

  def test_all
  end

  def test_destroy
    skip 'pending'
  end
end
