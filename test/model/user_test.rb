require 'test_helper'

class UserTest < Minitest::Test
  def test_create
    args = test_user_create_args
    user = SynapsePayRest::User.create(args)
    # shift @ off from instance var names
    instance_variables = user.instance_variables.map { |var| var.to_s[1..-1].to_sym }
    # confirm all fields assigned to instance variables (check union of arrays)
    assert_empty args.keys - instance_variables
    refute_nil user.id
    # confirm refresh token from API response saved
    refute_nil user.refresh_token
    # oauthed
    refute_empty user.client.http_client.config[:oauth_key]
  end

  def test_create_user_with_incomplete_info
    args = test_user_create_args
    args.delete(:logins)

    assert_raises(ArgumentError) { SynapsePayRest::User.create(args) }

    args_with_empty_array = test_user_create_args
    args_with_empty_array[:phone_numbers] = []

    assert_raises(ArgumentError) { SynapsePayRest::User.create(args_with_empty_array) }

    args_with_blank_email = test_user_create_args
    args_with_blank_email[:logins] = [{email: '', password: 'test1234', read_only: false}]

    assert_raises(ArgumentError) { SynapsePayRest::User.create(args_with_blank_email) }
  end

  def test_find
    user = test_user_with_base_document_with_three_documents
    user_instance = SynapsePayRest::User.find(client: test_client, id: user.id)
    user_data_from_api = test_client.users.get(user_id: user.id)

    assert_instance_of SynapsePayRest::User, user_instance
    assert_equal user_data_from_api['_id'], user_instance.id
    assert_equal user_data_from_api['logins'], user_instance.logins

    # confirm documents survive being submitted and fetched
    refute_empty user_instance.base_documents
    refute_nil user_instance.base_documents.first.id
    refute_empty user_instance.base_documents.first.social_documents
    refute_empty user_instance.base_documents.first.physical_documents
    refute_empty user_instance.base_documents.first.virtual_documents

    # confirm documents contain all data from response
    refute_nil user_instance.base_documents.first.virtual_documents.first.id
    refute_nil user_instance.base_documents.first.virtual_documents.first.status
    refute_nil user_instance.base_documents.first.virtual_documents.first.last_updated
    refute_nil user_instance.base_documents.first.virtual_documents.first.type

    # 3 + 1 because the phone number from base doc is auto-added to documents
    assert_equal 1, user_instance.base_documents.first.virtual_documents.count
  end

  def test_find_user_with_non_existent_id_raises_error
    assert_raises SynapsePayRest::Error::NotFound do
      SynapsePayRest::User.find(client: test_client, id: '1234567890')
    end
  end

  def test_all
    user_instances = SynapsePayRest::User.all(client: test_client)
    user_instance  = user_instances.first

    # not oauthed
    assert_empty user_instance.client.http_client.config[:oauth_key]
    # not same client
    refute_equal user_instance.client, user_instances[1].client
    assert_instance_of Array, user_instances
    assert_equal 20, user_instances.length
    assert_instance_of SynapsePayRest::User, user_instance
    assert_operator user_instance.id.length, :>, 0
    assert_instance_of Array, user_instance.logins
    assert_instance_of Array, user_instance.phone_numbers
    assert_instance_of Array, user_instance.legal_names
  end

  def test_all_with_page
    page1 = SynapsePayRest::User.all(client: test_client, page: 1)
    page2 = SynapsePayRest::User.all(client: test_client, page: 2)

    # same record does not appear on both pages
    refute_equal page1.first.id, page2.first.id
  end

  def test_all_with_per_page
    page = SynapsePayRest::User.all(client: test_client, per_page: 10)
    assert_equal 10, page.length
  end

  def test_all_with_no_users
    skip 'mock needed. tested manually for now.'
    users = SynapsePayRest::User.all(client: test_client)
    assert_empty users
  end

  def test_search
    query   = 'Betty'
    results = SynapsePayRest::User.search(client: test_client, query: query)

    assert results.all? do |user|
      user.legal_names.find { |name| name.include?(query)} ||
        user.logins.find { |login| login.email.include? query }
    end

    results2 = SynapsePayRest::User.search(client: test_client, query: 'asdfkl;fja')
    assert_empty results2
  end

  def test_search_with_page_and_per_page
    query = '.com'
    page1 = SynapsePayRest::User.search(client: test_client, query: query, page: 2, per_page: 3)
    assert_equal 3, page1.length

    page2 = SynapsePayRest::User.search(client: test_client, query: query, page: 3, per_page: 2)
    assert_equal 2, page2.length
    refute_equal page1.first.id, page2.first.id
  end

  def test_update
    user = test_user
    args = test_user_update_args
    user = user.update(args)

    # verify instance variables reassigned
    assert user.logins.any? { |l| l['email'] == args[:login][:email] }
    assert_includes user.phone_numbers, args[:phone_number]
    refute_includes user.logins, args[:remove_login]
    refute_includes user.phone_numbers, args[:remove_phone_number]

    # verify that it's updated
    api_response = test_client.users.get(user_id: user.id)
    assert api_response['logins'].any? do |login|
      login['email'] == args[:login][:email]
    end
    assert_includes api_response['legal_names'], args[:legal_name]
    assert_includes api_response['phone_numbers'], args[:phone_number]

    # remove some info
    user.update(
      remove_login:        {email: args[:login][:email]},
      remove_phone_number: args[:phone_number]
    )
    api_response2 = test_client.users.get(user_id: user.id)

    # verify that it's removed
    refute api_response2['logins'].any? { |login| login['email'] == args[:login][:email] }
    refute_includes api_response2['phone_numbers'], args[:phone_number]
  end

  def test_create_base_document
    user = test_user
    args = test_base_document_args_with_three_documents
    args.delete(:user)
    base_document = user.create_base_document(args)
    user = base_document.user

    refute_empty user.base_documents
    assert user.base_documents.first.social_documents.any? { |d| d.type == args[:social_documents].first.type }
    assert_equal user, user.base_documents.first.user
  end

  def test_with_multiple_base_documents
    user = test_user
    args1 = test_base_document_args_with_three_documents
    args1.delete(:user)
    args2 = test_base_document_args_with_three_documents
    args2.delete(:user)
    base_document1 = user.create_base_document(args1)
    base_document2 = user.create_base_document(args2)
    user = base_document2.user

    assert_equal 2, user.base_documents.length
    refute_equal user.base_documents.first, user.base_documents.last
  end

  def test_add_login
    user = test_user
    login = {email: 'test@test.com', password: "letmein"}
    user = user.add_login(login)
    assert user.logins.any? { |l| l['email'] == login[:email] }

    # verify added in api
    response = test_client.users.get(user_id: user.id)
    assert response['logins'].any? { |l| l['email'] == login[:email] }
  end

  def test_remove_login
    user = test_user
    login = {email: 'test@test.com', password: 'letmein'}
    user = user.add_login(login)
    assert user.logins.any? { |l| l['email'] == login[:email] }

    user = user.remove_login(email: login[:email])
    refute user.logins.any? { |l| l['email'] == login[:email] }

    # verify removed in api
    response = test_client.users.get(user_id: user.id)
    refute response['logins'].any? { |l| l['email'] == login[:email] }
  end

  def test_add_phone_number
    user = test_user
    phone_number = '555-555-5555'
    user = user.add_phone_number(phone_number)
    assert_includes user.phone_numbers, phone_number

    # verify added in api
    response = test_client.users.get(user_id: user.id)
    assert_includes response['phone_numbers'], phone_number
  end

  def test_remove_phone_number
    user = test_user
    phone_number = '555-555-5555'
    user = user.add_phone_number(phone_number)
    assert_includes user.phone_numbers, phone_number

    user = user.remove_phone_number(phone_number)
    refute_includes user.phone_numbers, phone_number

    # verify removed in api
    response = test_client.users.get(user_id: user.id)
    refute_includes response['phone_numbers'], phone_number
  end

  def test_remove_legal_name
    user = test_user
    legal_name = 'Remove Legal Name'
    user = user.add_legal_name(legal_name)
    assert_includes user.legal_names, legal_name

    user = user.remove_legal_name(legal_name)
    refute_includes user.legal_names, legal_name

    # verify removed in api
    response = test_client.users.get(user_id: user.id)
    refute_includes response['legal_names'], legal_name
  end

  def test_register_new_fingerprint
    user = test_user
    devices = user.register_fingerprint('static_pin')
    assert_instance_of Array, devices
    assert_operator devices.length, :>, 0

    confirmation = user.select_2fa_device(devices.first)
    assert_equal :success, confirmation

    confirmation = user.confirm_2fa_pin(device: devices.first, pin: '123456')
    assert_equal :success, confirmation
  end

  def test_nodes
    user = test_user
    assert_empty user.nodes

    user_with_nodes = test_user_with_two_nodes
    nodes = user_with_nodes.nodes
    assert_equal 2, nodes.length
    assert_kind_of SynapsePayRest::BaseNode, nodes.first
  end

  def test_find_node
    user  = test_user_with_two_nodes
    nodes = user.nodes
    assert_equal 2, nodes.length

    node1 = user.find_node(id: nodes.first.id)
    node2 = user.find_node(id: nodes.last.id)

    assert_equal nodes.first, node1
    assert_equal nodes.last, node2
  end

  def test_create_ach_us_node
    user = test_user
    args = test_ach_us_create_args
    args.delete(:user)
    node = user.create_ach_us_node(args)

    assert_instance_of SynapsePayRest::AchUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_ach_us_nodes_via_bank_login
    user = test_user
    args = test_ach_us_create_via_bank_login_args
    args.delete(:user)
    nodes = user.create_ach_us_nodes_via_bank_login(args)

    assert_instance_of SynapsePayRest::AchUsNode, nodes.first
    assert_includes user.nodes, nodes.first
  end

  def test_create_eft_ind_node
    skip 'deprecated'
    user = test_user
    args = test_eft_ind_create_args
    args.delete(:user)
    node = user.create_eft_ind_node(args)

    assert_instance_of SynapsePayRest::EftIndNode, node
    assert_includes user.nodes, node
  end

  def test_create_eft_np_node
    skip 'deprecated'
    user = test_user
    args = test_eft_np_create_args
    args.delete(:user)
    node = user.create_eft_np_node(args)

    assert_instance_of SynapsePayRest::EftNpNode, node
    assert_includes user.nodes, node
  end

  def test_create_iou_node
    user = test_user
    args = test_iou_create_args
    args.delete(:user)
    node = user.create_iou_node(args)

    assert_instance_of SynapsePayRest::IouNode, node
    assert_includes user.nodes, node
  end

  def test_create_reserve_us_node
    user = test_user
    args = test_reserve_us_create_args
    args.delete(:user)
    node = user.create_reserve_us_node(args)

    assert_instance_of SynapsePayRest::ReserveUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_synapse_ind_node
    skip 'deprecated'
    user = test_user
    args = test_synapse_ind_create_args
    args.delete(:user)
    node = user.create_synapse_ind_node(args)

    assert_instance_of SynapsePayRest::SynapseIndNode, node
    assert_includes user.nodes, node
  end

  def test_create_synapse_np_node
    skip 'deprecated'
    user = test_user
    args = test_synapse_np_create_args
    args.delete(:user)
    node = user.create_synapse_np_node(args)

    assert_instance_of SynapsePayRest::SynapseNpNode, node
    assert_includes user.nodes, node
  end

  def test_create_deposit_us_node
    user = test_user
    args = test_synapse_us_create_args
    args.delete(:user)
    node = user.create_deposit_us_node(args)

    assert_instance_of SynapsePayRest::DepositUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_synapse_us_node
    user = test_user
    args = test_synapse_us_create_args
    args.delete(:user)
    node = user.create_synapse_us_node(args)

    assert_instance_of SynapsePayRest::SynapseUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_subaccount_us_node
    user = test_user
    args = test_subaccount_us_create_args
    args.delete(:user)
    node = user.create_subaccount_us_node(args)
    assert_instance_of SynapsePayRest::SubaccountUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_triumph_subaccount_us_node
    user = test_user
    args = test_synapse_us_create_args
    args.delete(:user)
    node = user.create_triumph_subaccount_us_node(args)

    assert_instance_of SynapsePayRest::TriumphSubaccountUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_wire_us_node
    user = test_user
    args = test_wire_us_create_args
    args.delete(:user)
    node = user.create_wire_us_node(args)

    assert_instance_of SynapsePayRest::WireUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_wire_int_node
    user = test_user
    args = test_wire_int_create_args
    args.delete(:user)
    node = user.create_wire_int_node(args)

    assert_instance_of SynapsePayRest::WireIntNode, node
    assert_includes user.nodes, node
  end

  def test_create_check_us_node
    user = test_user
    args = test_check_us_create_args
    args.delete(:user)
    node = user.create_check_us_node(args)

    assert_instance_of SynapsePayRest::CheckUsNode, node
    assert_includes user.nodes, node
  end
##
  def test_create_ib_deposit_us_node
    user = test_user
    args = test_ib_deposit_us_create_args
    args.delete(:user)
    node = user.create_ib_deposit_us_node(args)

    assert_instance_of SynapsePayRest::IbDepositUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_ib_subaccount_us_node
    user = test_user
    args = test_ib_subaccount_us_create_args
    args.delete(:user)
    node = user.create_ib_subaccount_us_node(args)

    assert_instance_of SynapsePayRest::IbSubaccountUsNode, node
    assert_includes user.nodes, node
  end

  def test_clearing_us_node
    user = test_user
    args = test_clearing_us_create_args
    args.delete(:user)
    node = user.create_clearing_us_node(args)

    assert_instance_of SynapsePayRest::ClearingUsNode, node
    assert_includes user.nodes, node
  end

  def test_interchange_us_node
    user = test_user_with_base_doc
    sleep(15)
    id = user.base_documents[0].id

    args2 = {
            nickname: 'Debit Card',
            card_number: "Zoo8g2vBUjt7TwmEpRW8f6eQT3AOEEYePw2LkoxD+mO9lOT5OemHlGwgamgLGUbrmWu3DPwnEr2IqDy5YMFVgvQWP3w9nLOFzFFSW43auDgsVAqZScoRf8nI+6/B9KvOEV4XI8JeyXT+O+y3p3RtbiXGmYQNJ56Hy3hs2E5O+yn+3fpLfJQpVvNc38V+aE21VEsJuXFFNtS/8r4jJ6Dx/etTEaE/rtcEUEbwLLHFHjPiOWaHWZPuhXFLtyYrR9zG8FWSJVFwNTG/mEpv2O7We1iCB+9WoEKqdHyGwjjBcVgkUlU5huJIXv9xj53RGNvmHkDFTqgrlHpKkb0E/Ot0Zg==",
            exp_date: "ctA4Zj1CP0WCiMefPYsyewVbIHNilfwA09X9NSCyWxft4WGwFZmZkhsBJh51QL751/iFkUHbd09ZpDYjS86PqyNPZ5LkBueGHDIghLwWyzH1l99RiIs8urOW9c4g3L1USD+kzzRAqG1DBkW47FAX6AhPSi3YgQd94ery1H+asaqDrP79ayzoJ+nRXeEqe83FIgNUk/J5+EcAz3JYnoBmp1sfz7a4zHkvk0eKCxQWLETdqvONyCZyXdC/4CkaCxJ/87VsN3i4+ToULtSluRv8xr1NpRhzipKiEKTYW1nvNDAaJQezTVP/+GxmTmQfnfpVNDpJbXjNrOTej1HgMFpg4w==",
            document_id: id
          }
    node = user.create_interchange_us_node(args2)

    assert_instance_of SynapsePayRest::InterchangeUsNode, node
    assert_includes user.nodes, node
  end

  def test_card_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(10)
    args2 = {
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = user.create_card_us_node(args2)

    assert_instance_of SynapsePayRest::CardUsNode, node
    assert_includes user.nodes, node
  end

  def test_subcard_us_node
    user = test_user_with_base_doc
    id = user.base_documents[0].id
    sleep(10)
    args2 = {
            nickname: 'Debit Card',
            document_id: id,
            card_type: 'PHYSICAL'
          }
    node = user.create_subcard_us_node(args2)

    assert_instance_of SynapsePayRest::SubcardUsNode, node
    assert_includes user.nodes, node
  end

  def test_create_crypto_us_node
    user = test_user
    args = test_crypto_us_create_args
    args.delete(:user)
    node = user.create_crypto_us_node(args)

    assert_instance_of SynapsePayRest::CryptoUsNode, node
    assert_includes user.nodes, node
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
    response = user.get_statement()

    refute_nil response[1].pdf_url
    refute_nil response[1].csv_url
    refute_nil response[1].json_url
  end
end
