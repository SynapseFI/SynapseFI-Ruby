require 'test_helper'

class NodeTest < Minitest::Test
  def setup
    @user = test_user
  end

  # TODO: test with both maximum and minimum fields
  # TODO: run through all node types when finished
  def test_create_synapse_us
    args = {
      user: @user,
      nickname: 'Test Synapse Account',
      supp_id: 'abc123'
    }
    node = SynapsePayRest::SynapseUsNode.create(args)

    other_instance_vars = [:is_active, :account_id, :balance, :currency,
                           :name_on_account, :allowed]

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
                           :allowed]

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
                           :allowed, :bank_name, :balance, :currency, :routing_number,
                           :account_number, :account_class, :account_type]

    assert_instance_of Array, nodes

    nodes.each do |node|
      assert_instance_of SynapsePayRest::AchUsNode, node
      assert_equal @user, node.user
      assert_includes @user.nodes, node
      # verify instance vars readable and mapped to values
      other_instance_vars.each { |var| refute_nil node.send(var) }
    end
  end

  def test_create_ach_us_via_bank_login_with_mfa_questions
    skip 'pending'
  end
end
