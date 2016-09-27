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
      supp_id: 'abc123',
      gateway_restricted: false
    }
    node = SynapsePayRest::SynapseUsNode.create(args)

    assert_instance_of SynapsePayRest::SynapseUsNode, node
    assert_equal @user, node
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each { |k, v| assert_equal args[k], v }
  end

  def test_create_ach_us_via_account_routing_numbers
    args = {
      user: @user,
      nickname: 'Test ACH Account',
      account_number: '23456543234567543234567',
      routing_number: '051000017',
      account_type: 'PERSONAL',
      account_class: 'CHECKING',
      supp_id: 'abc123',
      gateway_restricted: false
    }
    node = SynapsePayRest::AchUsNode.create(args)

    assert_instance_of SynapsePayRest::AchUsNode, node
    assert_includes @user.nodes, node
    assert_equal @user, node.user
    # verify instance vars readable and mapped to values
    args.each { |k, v| assert_equal args[k], v }
  end
end
