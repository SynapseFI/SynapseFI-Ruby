require 'test_helper'

class NodeTest < Minitest::Test
  def setup
    @user = test_user
  end

  def test_find
    args = test_ach_us_create_via_bank_login_args(user: @user)
    nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)
    node = SynapsePayRest::Node.find(user: @user, id: nodes.first.id)

    assert_equal nodes.first.id, node.id
    assert_kind_of SynapsePayRest::BaseNode, node
    assert_instance_of SynapsePayRest::AchUsNode, node
    assert_includes @user.nodes, node
  end

  def test_all
    user = test_user_with_two_nodes
    nodes = SynapsePayRest::Node.all(user: user)

    assert_equal 2, nodes.length
    nodes.each do |node|
      assert_kind_of SynapsePayRest::BaseNode, node
      assert_instance_of SynapsePayRest::AchUsNode, node
      assert_includes user.nodes, node
    end
  end

  def test_all_with_page_and_per_page
    user = test_user_with_two_nodes

    page1 = SynapsePayRest::Node.all(user: user, page: 1, per_page: 1)
    assert_equal 1, page1.length
    assert_kind_of SynapsePayRest::BaseNode, page1.first
    assert_instance_of SynapsePayRest::AchUsNode, page1.first
    assert_includes user.nodes, page1.first

    page2 = SynapsePayRest::Node.all(user: user, page: 2, per_page: 1)
    assert_equal 1, page2.length
    assert_kind_of SynapsePayRest::BaseNode, page2.first
    assert_instance_of SynapsePayRest::AchUsNode, page2.first
    assert_includes user.nodes, page2.first
    refute_equal page1.first.id, page2.first.id

    long_page = SynapsePayRest::Node.all(user: user, page: 1, per_page: 2)
    assert_equal 2, long_page.length
  end

  # TODO: test with more types
  def test_by_type
    user = test_user_with_two_nodes

    ach_us_results = SynapsePayRest::Node.by_type(user: user, type: 'ACH-US')
    assert_equal 2, ach_us_results.length

    synapse_us_results = SynapsePayRest::Node.by_type(user: user, type: 'SYNAPSE-US')
    assert_empty synapse_us_results
  end

  def test_all_with_no_nodes
    nodes = SynapsePayRest::Node.all(user: @user, page: 1, per_page: 1)
    assert_empty nodes
  end

  def test_transactions
    skip 'pending'
  end

  def test_find_transaction
    skip 'pending'
  end

  def test_destroy
    user = test_user_with_two_nodes

    assert_equal 2, user.nodes.length
    user.nodes.first.destroy
    assert_equal 1, user.nodes.length
    user.nodes.last.destroy
    assert_empty user.nodes
  end

  def test_create_ach_us_via_account_routing_numbers
    args = test_ach_us_create_args(user: @user)
    node = SynapsePayRest::AchUsNode.create(args)

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions, :type]

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

  def test_create_ach_us_with_wrong_acct_routing
    skip 'pending'
  end

  def test_create_ach_us_with_wrong_microdeposit
    skip 'pending'
  end

  # TOOD: handle incorrect login info
  def test_create_ach_us_via_bank_login
    args = test_ach_us_create_via_bank_login_args(user: @user)
    nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions, :bank_name, :balance, :currency, :routing_number,
                           :account_number, :account_class, :account_type, :type]

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
    args = test_ach_us_create_via_bank_login_args(user: @user, username: 'synapse_good')
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_instance_of SynapsePayRest::UnverifiedNode, unverified_node
    assert unverified_node.mfa_verified == false
    refute_nil unverified_node.mfa_access_token
    refute_nil unverified_node.mfa_message

    unverified_node.answer_mfa(answer: 'test_answer')
    assert unverified_node.mfa_verified == true

    other_instance_vars = [:is_active, :bank_long_name, :name_on_account,
                           :permissions, :bank_name, :balance, :currency, :routing_number,
                           :account_number, :account_class, :account_type, :type]

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

  def test_create_ach_us_via_bank_login_with_wrong_login
    skip 'pending'
  end

  def test_create_ach_us_via_bank_login_with_wrong_mfa_answers
    skip 'pending'
  end

  def test_create_eft_ind_node
    args = test_eft_ind_create_args(user: @user)
    node = SynapsePayRest::EftIndNode.create(args)

    assert_instance_of SynapsePayRest::EftIndNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number, :ifsc].include? var_name
        # these are sliced to last 4 digits in response
        assert_equal value[-4..-1], node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_eft_np_node
    args = test_eft_np_create_args(user: @user)
    node = SynapsePayRest::EftNpNode.create(args)

    assert_instance_of SynapsePayRest::EftNpNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type]

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

  def test_create_iou_node
    args = test_iou_create_args(user: @user)
    node = SynapsePayRest::IouNode.create(args)

    assert_instance_of SynapsePayRest::IouNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type]

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

  def test_create_reserve_us_node
    args = test_reserve_us_create_args(user: @user)
    node = SynapsePayRest::ReserveUsNode.create(args)

    assert_instance_of SynapsePayRest::ReserveUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type, :balance, :currency]

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

  def test_create_synapse_ind_node
    args = test_synapse_ind_create_args(user: @user)
    node = SynapsePayRest::SynapseIndNode.create(args)

    assert_instance_of SynapsePayRest::SynapseIndNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type]

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

  def test_create_synapse_np_node
    args = test_synapse_np_create_args(user: @user)
    node = SynapsePayRest::SynapseNpNode.create(args)

    assert_instance_of SynapsePayRest::SynapseNpNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permissions, :type]

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

  # TODO: test with both maximum and minimum fields
  def test_create_synapse_us_node
    args = test_synapse_us_create_args(user: @user)
    node = SynapsePayRest::SynapseUsNode.create(args)

    other_instance_vars = [:is_active, :account_id, :balance, :currency,
                           :name_on_account, :permissions, :type]

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

  def test_create_wire_int_node
    args = test_wire_int_create_args(user: @user)
    node = SynapsePayRest::WireIntNode.create(args)
  binding.pry
    other_instance_vars = [:is_active, :permissions, :type]

    assert_instance_of SynapsePayRest::WireIntNode, node
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

  def test_create_wire_us_node
    args = test_wire_us_create_args(user: @user)
    node = SynapsePayRest::WireUsNode.create(args)

    other_instance_vars = [:is_active, :permissions, :type]

    assert_instance_of SynapsePayRest::WireUsNode, node
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
end
