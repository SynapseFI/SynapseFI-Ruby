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
    assert_instance_of Array, user_instances
    assert_equal 20, user_instances.length
    assert_instance_of SynapsePayRest::User, user_instance
    assert_operator user_instance.id.length, :>, 0
    assert_instance_of Array, user_instance.logins
    assert_instance_of Array, user_instance.phone_numbers
    assert_instance_of Array, user_instance.legal_names
  end

  def test_all_with_no_users
    skip 'pending'
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
    skip 'pending'
  end

  def test_update
    user = test_user
    args = test_user_update_args
    user.update(args)

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
    user.create_base_document(args)

    refute_empty user.base_documents
    assert_equal args[:social_documents].first, user.base_documents.first.social_documents.first
    assert_equal user, user.base_documents.first.user
  end

  def test_with_multiple_base_documents
    skip 'pending'
  end

  def test_fetch_nodes
    skip 'pending'
    user = test_user
    user.fetch_nodes
  end

  def test_nodes
    user = test_user
    assert_empty user.nodes

    user_with_nodes = test_user_with_two_nodes
    nodes = user_with_nodes.nodes
    assert_equal 2, nodes.length
    assert_kind_of SynapsePayRest::BaseNode, nodes.first
  end

  def test_create_node
    skip 'pending'
  end

  def test_find_node
    skip 'pending'
  end

  def test_mfa_on_signin
    skip 'pending'
  end

  def test_mfa_on_create_document
    skip 'pending'
  end

  def test_mfa_on_update_document
    skip 'pending'
  end
end
