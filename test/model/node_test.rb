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

  def test_all_with_no_nodes
    nodes = SynapsePayRest::Node.all(user: @user, page: 1, per_page: 1)
    assert_empty nodes
  end

  def test_by_type
    user = test_user_with_two_nodes

    ach_us_results = SynapsePayRest::Node.by_type(user: user, type: 'ACH-US')
    assert_equal 2, ach_us_results.length

    synapse_us_results = SynapsePayRest::Node.by_type(user: user, type: 'SYNAPSE-US')
    assert_empty synapse_us_results

    # create 2 synapse-us nodes
    test_synapse_us_node(user: user)
    test_synapse_us_node(user: user)
    synapse_us_results2 = SynapsePayRest::Node.by_type(user: user, type: 'SYNAPSE-US')
    assert_equal 2, synapse_us_results2.length
  end

  def test_create_transaction
    user = test_user_with_two_nodes
    nodes = user.nodes
    from_node, to_node = nodes.first, nodes.last
    args = test_transaction_create_args(node: from_node, to_type: to_node.type, to_id: to_node.id)
    args.delete(:node)
    transaction = from_node.create_transaction(args)

    assert_kind_of SynapsePayRest::Transaction, transaction
    assert_equal from_node, transaction.node
    assert_equal to_node.id, transaction.to['id']
  end

  def test_transactions
    user      = test_user_with_two_nodes
    nodes     = user.nodes
    from_node = nodes.first
    to_node   = nodes.last
    assert_empty from_node.transactions

    transaction1 = test_transaction(node: from_node, to_type: 'ACH-US', to_id: to_node.id)
    transactions = from_node.transactions
    assert_equal 1, transactions.length
    assert_instance_of SynapsePayRest::Transaction, transactions.first

    transaction2 = test_transaction(node: from_node, to_type: 'ACH-US', to_id: to_node.id)
    assert_equal 2, from_node.transactions.length
  end

  def test_find_transaction
    user      = test_user_with_two_nodes
    nodes     = user.nodes
    from_node = nodes.first
    to_node   = nodes.last
    transaction1 = test_transaction(node: from_node, to_type: 'ACH-US', to_id: to_node.id)
    transaction2 = test_transaction(node: from_node, to_type: 'ACH-US', to_id: to_node.id)

    found_transaction = from_node.find_transaction(id: transaction2.id)
    refute_equal transaction1, found_transaction
    assert_equal transaction2, found_transaction
  end

  def test_deactivate
    user = test_user_with_two_nodes

    assert_equal 2, user.nodes.length
    deactivated_node1 = user.nodes.first.deactivate
    refute deactivated_node1.is_active
    assert_equal 1, user.nodes.length
    deactivated_node2 = user.nodes.last.deactivate
    refute deactivated_node2.is_active
    assert_empty user.nodes
  end

  def test_create_ach_us_via_account_routing_numbers
    args = test_ach_us_create_args(user: @user)
    node = SynapsePayRest::AchUsNode.create(args)
    
    other_instance_vars = [:is_active, :bank_long_name, :permission, :type]

    assert_instance_of SynapsePayRest::AchUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }

    assert_equal 'CREDIT', node.permission
    # resend microdeposits
    node = node.resend_micro()
    # verify microdeposits
    node = node.verify_microdeposits(amount1: 0.1, amount2: 0.1)
    assert_equal 'CREDIT-AND-DEBIT', node.permission
  end

  def test_create_ach_us_with_wrong_acct_routing
    args = test_ach_us_create_args(user: @user, routing_number: '11111')
    assert_raises(SynapsePayRest::Error) { SynapsePayRest::AchUsNode.create(args) }
  end

  def test_create_ach_us_with_wrong_microdeposit
    args = test_ach_us_create_args(user: @user)
    node = SynapsePayRest::AchUsNode.create(args)

    assert_equal 'CREDIT', node.permission
    # resend microdeposits
    node = node.resend_micro()
    # verify microdeposits
    assert_raises(SynapsePayRest::Error) { node.verify_microdeposits(amount1: 0.2, amount2: 0.2) }
    assert_equal 'CREDIT', node.permission
  end

  def test_create_ach_us_with_microdeposit_and_already_verified
    args = test_ach_us_create_args(user: @user)
    node = SynapsePayRest::AchUsNode.create(args)

    assert_equal 'CREDIT', node.permission
    # resend microdeposits
    node = node.resend_micro()
    # verify microdeposits
    node = node.verify_microdeposits(amount1: 0.1, amount2: 0.1)
    assert_equal 'CREDIT-AND-DEBIT', node.permission

    # verify again
    assert_raises(SynapsePayRest::Error) {node.verify_microdeposits(amount1: 0.2, amount2: 0.2)}
    assert_equal 'CREDIT-AND-DEBIT', node.permission
  end

  def test_create_ach_us_via_bank_login
    args = test_ach_us_create_via_bank_login_args(user: @user)
    nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    other_instance_vars = [:is_active, :bank_long_name, :permission, :bank_name,
                           :currency, :routing_number, :type,
                           :account_number, :account_class, :account_type,
                           :email_match, :name_match, :phonenumber_match]

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
    args = test_ach_us_create_via_bank_login_args(user: @user, password: 'foo')
    assert_raises(SynapsePayRest::Error) { SynapsePayRest::AchUsNode.create_via_bank_login(args) }
  end

  def test_create_ach_us_via_bank_login_with_mfa_questions
    args = test_ach_us_create_via_bank_login_args(user: @user, username: 'synapse_good')
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_instance_of SynapsePayRest::UnverifiedNode, unverified_node
    refute unverified_node.mfa_verified
    refute_nil unverified_node.mfa_access_token
    refute_nil unverified_node.mfa_message

    unverified_node.answer_mfa('test_answer')
    assert unverified_node.mfa_verified

    other_instance_vars = [:is_active, :bank_long_name,
                           :permission, :bank_name, :currency, :routing_number,
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

  def test_create_ach_us_via_bank_login_with_mfa_questions2
    args = test_ach_us_create_via_bank_login_args(user: @user, username: 'synapse_good')
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_instance_of SynapsePayRest::UnverifiedNode, unverified_node
    refute unverified_node.mfa_verified
    refute_nil unverified_node.mfa_access_token
    refute_nil unverified_node.mfa_message

    args = test_ach_us_create_via_bank_login_mfa_args(user: @user, access_token: unverified_node.mfa_access_token)
    unverified_node2 = SynapsePayRest::AchUsNode.create_via_bank_login_mfa(args)
    refute unverified_node2.mfa_verified

    unverified_node2.answer_mfa('test_answer')
    assert unverified_node2.mfa_verified

    other_instance_vars = [:is_active, :bank_long_name,
                           :permission, :bank_name, :currency, :routing_number,
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

  def test_create_ach_us_via_bank_login_with_wrong_mfa_answers
    args = test_ach_us_create_via_bank_login_args(user: @user, username: 'synapse_good')
    unverified_node = SynapsePayRest::AchUsNode.create_via_bank_login(args)

    assert_instance_of SynapsePayRest::UnverifiedNode, unverified_node
    refute unverified_node.mfa_verified
  end

  def test_create_eft_ind_node
    skip 'deprecated'
    args = test_eft_ind_create_args(user: @user)
    node = SynapsePayRest::EftIndNode.create(args)

    assert_instance_of SynapsePayRest::EftIndNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permission, :type]

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
    skip 'deprecated'
    args = test_eft_np_create_args(user: @user)
    node = SynapsePayRest::EftNpNode.create(args)

    assert_instance_of SynapsePayRest::EftNpNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permission, :type]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
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

    other_instance_vars = [:is_active, :permission, :type]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
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

    other_instance_vars = [:is_active, :permission, :type, :balance, :currency]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_synapse_ind_node
    skip 'deprecated'
    args = test_synapse_ind_create_args(user: @user)
    node = SynapsePayRest::SynapseIndNode.create(args)

    assert_instance_of SynapsePayRest::SynapseIndNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :balance, :currency, :name_on_account,
                           :permission, :type]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_synapse_np_node
    skip 'deprecated'
    args = test_synapse_np_create_args(user: @user)
    node = SynapsePayRest::SynapseNpNode.create(args)

    assert_instance_of SynapsePayRest::SynapseNpNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :balance, :currency, :name_on_account,
                           :permission, :type]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  # @todo test with both maximum and minimum fields
  def test_create_synapse_us_node
    args = test_synapse_us_create_args(user: @user)
    node = SynapsePayRest::SynapseUsNode.create(args)

    other_instance_vars = [:is_active, :balance, :currency, :permission, :type]

    assert_instance_of SynapsePayRest::SynapseUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_triumph_subaccount_us_node
    args = test_synapse_us_create_args(user: @user)
    node = SynapsePayRest::TriumphSubaccountUsNode.create(args)

    other_instance_vars = [:is_active, :balance, :currency, :permission, :type]

    assert_instance_of SynapsePayRest::TriumphSubaccountUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_subaccount_us_node
    args = test_synapse_us_create_args(user: @user)
    node = SynapsePayRest::SubaccountUsNode.create(args)
    other_instance_vars = [:is_active, :balance, :currency, :permission, :type]
    assert_instance_of SynapsePayRest::SubaccountUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_wire_int_node
    args = test_wire_int_create_args(user: @user)
    node = SynapsePayRest::WireIntNode.create(args)
 
    other_instance_vars = [:is_active, :permission, :type]
    not_returned = [:name_on_account, :correspondent_routing_number,
                    :correspondent_bank_name, :correspondent_address, :swift,
                    :correspondent_swift, :bank_name, :routing_number]
    assert_instance_of SynapsePayRest::WireIntNode, node
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number].include? var_name
        refute_nil node.send(var_name)
      elsif not_returned.include? var_name
        next
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end



  def test_create_wire_us_node
    args = test_wire_us_create_args(user: @user)
    node = SynapsePayRest::WireUsNode.create(args)

    other_instance_vars = [:is_active, :permission, :type, :bank_name]
    not_returned = [:name_on_account, :correspondent_routing_number,
                    :correspondent_bank_name, :correspondent_address, :swift,
                    :correspondent_swift]

    assert_instance_of SynapsePayRest::WireUsNode, node
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      elsif not_returned.include? var_name
        next
      else
        assert_equal value, node.send(var_name)
      end
    end

    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_check_us_node
    args = test_check_us_create_args(user: @user)
    node = SynapsePayRest::CheckUsNode.create(args)

    other_instance_vars = [:is_active, :permission, :type, :payee_name,
                           :address_street, :address_city, :address_subdivision,
                           :address_country_code, :address_postal_code]

    assert_instance_of SynapsePayRest::CheckUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node
    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end

    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_ib_deposit_us_node
    args = test_ib_deposit_us_create_args(user: @user)
    node = SynapsePayRest::IbDepositUsNode.create(args)

    assert_instance_of SynapsePayRest::IbDepositUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :balance, :currency, :monthly_withdrawals_remaining]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end
  
  def test_create_ib_subaccount_us_node
    args = test_ib_subaccount_us_create_args(user: @user)
    node = SynapsePayRest::IbSubaccountUsNode.create(args)

    assert_instance_of SynapsePayRest::IbSubaccountUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :balance, :currency, :monthly_withdrawals_remaining]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_clearing_us_node
    args = test_clearing_us_create_args(user: @user)
    node = SynapsePayRest::ClearingUsNode.create(args)

    assert_instance_of SynapsePayRest::ClearingUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :balance, :currency]

    # verify instance vars readable and mapped to values
    args.each do |var_name, value|
      if [:account_number, :routing_number].include? var_name
        refute_nil node.send(var_name)
      else
        assert_equal value, node.send(var_name)
      end
    end
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_interchange_us_node
    user = test_user_with_base_doc
    sleep(15)
    id = user.base_documents[0].id
    args = {
            user: user,
            nickname: 'Debit Card',
            card_number: "Zoo8g2vBUjt7TwmEpRW8f6eQT3AOEEYePw2LkoxD+mO9lOT5OemHlGwgamgLGUbrmWu3DPwnEr2IqDy5YMFVgvQWP3w9nLOFzFFSW43auDgsVAqZScoRf8nI+6/B9KvOEV4XI8JeyXT+O+y3p3RtbiXGmYQNJ56Hy3hs2E5O+yn+3fpLfJQpVvNc38V+aE21VEsJuXFFNtS/8r4jJ6Dx/etTEaE/rtcEUEbwLLHFHjPiOWaHWZPuhXFLtyYrR9zG8FWSJVFwNTG/mEpv2O7We1iCB+9WoEKqdHyGwjjBcVgkUlU5huJIXv9xj53RGNvmHkDFTqgrlHpKkb0E/Ot0Zg==",
            exp_date: "ctA4Zj1CP0WCiMefPYsyewVbIHNilfwA09X9NSCyWxft4WGwFZmZkhsBJh51QL751/iFkUHbd09ZpDYjS86PqyNPZ5LkBueGHDIghLwWyzH1l99RiIs8urOW9c4g3L1USD+kzzRAqG1DBkW47FAX6AhPSi3YgQd94ery1H+asaqDrP79ayzoJ+nRXeEqe83FIgNUk/J5+EcAz3JYnoBmp1sfz7a4zHkvk0eKCxQWLETdqvONyCZyXdC/4CkaCxJ/87VsN3i4+ToULtSluRv8xr1NpRhzipKiEKTYW1nvNDAaJQezTVP/+GxmTmQfnfpVNDpJbXjNrOTej1HgMFpg4w==",
            document_id: id
          }
    node = SynapsePayRest::InterchangeUsNode.create(args)

    assert_instance_of SynapsePayRest::InterchangeUsNode, node
    assert_equal user, node.user
    assert_includes user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :interchange_type, :network, :document_id, :card_hash, :is_international]


    # verify instance vars readable and mapped to values
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_card_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::CardUsNode.create(args)

    assert_instance_of SynapsePayRest::CardUsNode, node
    assert_equal user, node.user
    assert_includes user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :document_id, :allow_foreign_transactions, :atm_withdrawal_limit, :max_pin_attempts, :pos_withdrawal_limit, :security_alerts, :card_type]


    # verify instance vars readable and mapped to values
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_create_subcard_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::SubcardUsNode.create(args)

    assert_instance_of SynapsePayRest::SubcardUsNode, node
    assert_equal user, node.user
    assert_includes user.nodes, node

    other_instance_vars = [:is_active, :permission, :type, :document_id, :allow_foreign_transactions, :atm_withdrawal_limit, :max_pin_attempts, :pos_withdrawal_limit, :security_alerts, :card_type]


    # verify instance vars readable and mapped to values
    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_update_allowed_subcard_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::SubcardUsNode.create(args)

    node = node.update_allowed(allowed:'PENDING')

    assert_equal 'PENDING', node.permission
  end

  def test_update_allowed_card_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::CardUsNode.create(args)

    node = node.update_allowed(allowed:'PENDING')

    assert_equal 'PENDING', node.permission
  end

  def test_update_preferences_subcard_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::SubcardUsNode.create(args)

    args2 = {
              max_pin_attempts: 4
            }

    node = node.update_preferences(args2)

    assert_equal 4, node.max_pin_attempts
  end

  def test_update_preferences_card_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::CardUsNode.create(args)

    args2 = {
              max_pin_attempts: 4
            }

    node = node.update_preferences(args2)

    assert_equal 4, node.max_pin_attempts
  end

  def test_reissue_card
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::CardUsNode.create(args)
    sleep(5)

    node = node.reissue_card

    assert_equal 'INACTIVE', node.permission
  end

  def test_reorder_card
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(15)
    args = {
            user: user,
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = SynapsePayRest::CardUsNode.create(args)
    sleep(5)

    node = node.reorder_card

    assert_equal 'INACTIVE', node.permission
  end


  def test_create_crypto_us_node
    args = test_crypto_us_create_args(user: @user)
    node = SynapsePayRest::CryptoUsNode.create(args)

    other_instance_vars = [:is_active, :permission, :type, :access_token, :portfolio_BTC, :portfolio_ETH]

    assert_instance_of SynapsePayRest::CryptoUsNode, node
    assert_equal @user, node.user
    assert_includes @user.nodes, node

    other_instance_vars.each { |var| refute_nil node.send(var) }
  end

  def test_user_get_statement
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      ENV.fetch('FINGERPRINT'),
      development_mode: true
    } 
    client = SynapsePayRest::Client.new(@options)
    user = SynapsePayRest::User.find(client: client, id: '5a271c2592571b0034c0d9d8')
    node = user.find_node(id: '5a399beece31670034632427')
    response = node.get_statement()

    refute_nil response[1].pdf_url
    refute_nil response[1].csv_url
    refute_nil response[1].json_url
  end
end
