require 'test_helper'

class TransactionTest < Minitest::Test
  def setup
    @user      = test_user_with_two_nodes
    @from_node = @user.nodes.first
    @to_node   = @user.nodes.last
  end

  def test_create_with_fee
    fee_node_args = test_synapse_us_create_args
    fee_node_args.delete(:user)
    fee_node = @user.create_synapse_us_node(fee_node_args)

    refute_equal @from_node.id, @to_node.id

    args = test_transaction_create_args(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id,
      fee_amount: 2.00,
      fee_note: 'Test Fee',
      fee_to_id: fee_node.id
    )
    transaction = SynapsePayRest::Transaction.create(args)

    other_instance_vars = [
      :node, :amount, :currency, :client_id, :client_name, :created_on,
      :ip, :latlon, :note, :process_on, :supp_id, :webhook, :fees,
      :recent_status, :timeline, :from, :to, :to_type, :to_id
    ]

    assert_kind_of SynapsePayRest::BaseNode, transaction.node
    assert_equal @from_node, transaction.node
    assert_equal @to_node.id, transaction.to['id']
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

  def test_create_with_multiple_fees
    skip 'pending. not implemented.'
  end

  def test_create_without_fee
    transaction = test_transaction(node: @from_node, to_type: @to_node.type, to_id: @to_node.id,)

    assert_kind_of SynapsePayRest::BaseNode, transaction.node
    assert_equal @from_node, transaction.node
    assert_equal @to_node.id, transaction.to['id']
  end

  def test_create_with_insufficient_funds
    skip 'pending. does nothing different immediately.'

    args = test_transaction_create_args(
      node: @from_node,
      to_type: @to_node.type,
      to_id: @to_node.id,
      amount: 1_000_000
    )

    transaction = SynapsePayRest::Transaction.create(args)
  end

  def test_create_transaction_from_unverified_node
    args = test_ach_us_create_via_bank_login_args(user: @user, username: 'synapse_good')
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_raises(ArgumentError) { test_transaction(node: unverified_node, to_type: @to_node.type, to_id: @to_node.id) }
  end

  def test_create_with_insufficient_permission
    skip 'pending. does nothing differently currently(?)'
  end

  def test_ach_returns
    skip 'pending. mock needed (10-15 min delay).'
  end

  def test_find
    transaction = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )
    found_transaction = SynapsePayRest::Transaction.find(node: @from_node, id: transaction.id)

    assert_equal transaction, found_transaction
  end

  def test_all
    transaction1 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    transaction2 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    assert_equal 2, @from_node.transactions.length
    assert_instance_of SynapsePayRest::Transaction, @from_node.transactions.first
  end

  def test_all_with_page_and_per_page
    transaction1 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    transaction2 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    transaction3 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    assert_equal 3, @from_node.transactions.length
    assert_instance_of SynapsePayRest::Transaction, @from_node.transactions.first

    page1 = SynapsePayRest::Transaction.all(node: @from_node, page: 1, per_page: 2)
    assert_equal 2, page1.length

    page2 = SynapsePayRest::Transaction.all(node: @from_node, page: 3, per_page: 1)
    assert_equal 1, page2.length

    refute_includes page1, page2.first
  end

  def test_all_with_no_transactions
    transactions = SynapsePayRest::Transaction.all(node: @from_node)
    assert_empty transactions
  end

  def test_add_comment
    transaction = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )
    transaction.add_comment('testing 1 2 3')

    # verify comment added in api
    response = @user.client.transactions.get(
      user_id:  @user.id,
      node_id:  @from_node.id,
      trans_id: transaction.id
    )
    assert_includes response['recent_status']['note'], 'testing 1 2 3'
  end

  def test_cancel
    transaction1 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    transaction2 = test_transaction(
      node:    @from_node,
      to_type: @to_node.type,
      to_id:   @to_node.id
    )

    transaction1.cancel
    transaction2.cancel
    transactions = @from_node.transactions
    transactions.each do |t|
      assert_equal t.timeline.last['status'], 'CANCELED'
    end
  end
end
