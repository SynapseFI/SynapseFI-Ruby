require 'test_helper'

class NodeTest < Minitest::Test
  def setup
    @user = test_user
  end

  # TODO: test with both maximum and minimum fields
  # TODO: run through all node types when finished
  def test_create_synapse_us_node
    args = {
      user: @user,
      nickname: 'Test Synapse Account',
      supp_id: 'abc123'
    }
    node = SynapsePayRest::SynapseUsNode.create(args)

    other_instance_vars = [:is_active, :account_id, :balance, :currency,
                           :name_on_account, :permissions]

    assert_instance_of SynapsePayRest::SynapseUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        # these are sliced to last 4 digits in response
        assert_equal value[-4..-1], node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_ach_us_via_account_routing_numbers
    args = {
      user: @user,
      nickname: 'Test ACH Account',
      account_number: '23456543234567543234567',
      routing_number: '051000017',
      account_type: 'PERSONAL',
      account_class: 'CHECKING',
      supp_id: 'abc123'
    }
    node = SynapsePayRest::AchUsNode.create(args)

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions]

    assert_instance_of SynapsePayRest::AchUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        # these are sliced to last 4 digits in response
        assert_equal value[-4..-1], node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }

    assert_equal 'CREDIT', node.permissions
    # verify microdeposits
    node.verify_microdeposits(amount1: 0.1, amount2: 0.1)
    assert_equal 'CREDIT-AND-DEBIT', node.permissions
  end

  def test_create_ach_us_with_wrong_microdeposit
    skip 'pending'
  end

  def test_create_ach_us_via_bank_login
    args = {
      user: @user,
      bank_name: 'bofa',
      username: 'synapse_nomfa',
      password: 'test1234'
    }
    nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions, :bank_name, :balance, :currency, :routing_number,
                           :account_number, :account_class, :account_type]

    assert_instance_of Array, nodes
    assert_equal 2, nodes.length

    nodes.each do |node|
      assert_instance_of SynapsePayRest::AchUsNode, node
      assert_equal @user, node.user
      assert_includes @user.nodes, node
      # verify instance vars readable and mapped to values
      other_instance_vars.each { |var| refute_nil node.send(var) }
    end
  end

  def test_create_ach_us_via_bank_login_with_mfa_questions
    args = {
      user: @user,
      bank_name: 'bofa',
      username: 'synapse_good',
      password: 'test1234'
    }
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_instance_of SynapsePayRest::UnverifiedNode, unverified_node
    assert unverified_node.mfa_verified == false
    refute_nil unverified_node.mfa_access_token
    refute_nil unverified_node.mfa_message

    unverified_node.answer_mfa(answer: 'test_answer')
    assert unverified_node.mfa_verified == true

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions, :bank_name, :balance, :currency, :routing_number,
                           :account_number, :account_class, :account_type]

    nodes = @user.nodes
    assert_instance_of Array, nodes
    assert_equal 2, nodes.length

    nodes.each do |node|
      assert_instance_of SynapsePayRest::AchUsNode, node
      assert_equal @user, node.user
      assert_includes @user.nodes, node
      # verify instance vars readable and mapped to values
      other_instance_vars.each { |var| refute_nil node.send(var) }
    end
  end

  def test_create_ach_us_via_bank_login_with_wrong_mfa_answers
    skip 'pending'
  end

  def test_find
    node = Node.find(user: @user, id: @user.nodes.first.id)
    assert_kind_of SynapsePayRest::Node, node
    assert_instance_of SynapsePayRest::AchUsNode, node
    # TODO: probably need to overwrite existing node in user.nodes
    assert_equal @user.nodes.first, node
  end

  def test_all
    # create 2 nodes on @user
    args = {
      user: @user,
      bank_name: 'bofa',
      username: 'synapse_nomfa',
      password: 'test1234'
    }
    SynapsePayRest::AchUsNode.create_via_bank_login(args)

    nodes = SynapsePayRest::Node.all(user: @user)

    assert_equal 2, nodes.length
    nodes.each do |node|
      assert_kind_of SynapsePayRest::Node, node
      assert_instance_of SynapsePayRest::AchUsNode, node
      assert_includes @user.nodes, node
    end
  end

  def test_all_with_page_and_per_page
    # create 2 nodes on @user
    args = {
      user: @user,
      bank_name: 'bofa',
      username: 'synapse_nomfa',
      password: 'test1234'
    }
    SynapsePayRest::AchUsNode.create_via_bank_login(args)

    page1 = SynapsePayRest::Node.all(user: @user, page: 1, per_page: 1)
    assert_equal 1, page1.length
    assert_kind_of SynapsePayRest::Node, page1.first
    assert_instance_of SynapsePayRest::AchUsNode, page1.first
    # TODO: if caching removed, then need to change this
    assert_includes @user.nodes, page1.first

    page2 = SynapsePayRest::Node.all(user: @user, page: 2, per_page: 1)
    assert_equal 1, page2.length
    assert_kind_of SynapsePayRest::Node, page2.first
    assert_instance_of SynapsePayRest::AchUsNode, page2.first
    # TODO: if caching removed, then need to change this
    assert_includes @user.nodes, page2.first
    refute_equal page1.first.id, page2.first.id

    long_page = SynapsePayRest::Node.all(user: @user, page: 1, per_page: 2)
    assert_equal 2, long_page.length
  end

  # TODO: test with more types
  def test_by_type
    # create 2 nodes on @user
    args = {
      user: @user,
      bank_name: 'bofa',
      username: 'synapse_nomfa',
      password: 'test1234'
    }
    SynapsePayRest::AchUsNode.create_via_bank_login(args)

    ach_us_results = SynapsePayRest::Node.by_type(user: @user, type: 'ACH-US')
    assert_equal 2, ach_us_results.length

    synapse_us_results = SynapsePayRest::Node.by_type(user: @user, type: 'SYNAPSE-US')
    assert_empty synapse_us_results.length
  end

  def test_all_with_no_nodes
    nodes = SynapsePayRest::Node.all(user: @user, page: 1, per_page: 1)
    assert_empty nodes
  end

  def test_destroy
    user = test_user_with_two_nodes

    assert_equal 2, user.nodes.length
    user.nodes.first.destroy
    assert_equal 1, user.nodes.length
    user.nodes.first.destroy
    assert_empty user.nodes
  end
end
