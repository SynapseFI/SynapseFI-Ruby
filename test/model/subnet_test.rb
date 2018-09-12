require 'test_helper'

class SubnetTest < Minitest::Test
  def setup
    user       = test_user_with_deposit_node
    @user      = kyc_user(user)
    @node      = @user.nodes.first
  end

  def test_find
    subnet = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )
    found_subnet = SynapsePayRest::Subnet.find(node: @node, id: subnet.id)

    assert_equal subnet, found_subnet
  end

  def test_all
    subnet1 = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )

    subnet2 = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )

    assert_equal 2, @node.subnets.length
    assert_instance_of SynapsePayRest::Subnet, @node.subnets.first
  end

  def test_all_with_page_and_per_page
    subnet1 = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )

    subnet2 = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )


    subnet3 = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )


    assert_equal 3, @node.subnets.length
    assert_instance_of SynapsePayRest::Subnet, @node.subnets.first

    page1 = SynapsePayRest::Subnet.all(node: @node, page: 1, per_page: 2)
    assert_equal 2, page1.length

    page2 = SynapsePayRest::Subnet.all(node: @node, page: 3, per_page: 1)
    assert_equal 1, page2.length


    refute_includes page1, page2.first
  end

  def test_all_with_no_subnets
    subnets = SynapsePayRest::Subnet.all(node: @node)
    assert_empty subnets
  end

  def test_lock
    subnet = test_subnet(
      node:       @node,
      nickname:   "Subnet Test"
    )
    subnet.lock

    # verify comment added in api
    response = @user.client.subnets.get(
      user_id:  @user.id,
      node_id:  @node.id,
      subnet_id: subnet.id
    )
    assert_includes response['allowed'], 'LOCKED'
  end


end
