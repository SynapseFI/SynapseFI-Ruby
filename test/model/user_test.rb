require 'test_helper'

class UserTest < Minitest::Test
  def test_create
    info = {
      client: test_client,
      logins: [{email: 'rubyTest@synapsepay.com', password: 'test1234', read_only: false}],
      phone_numbers: ['901.111.1111'],
      legal_names: ['RUBY TEST USER'],
      note: 'Interesting user',
      supp_id: '122eddfgbeafrfvbbb',
      is_business: false
    }
    user = SynapsePayRest::User.create(info)
    # shift @ off from instance var names
    instance_variables = user.instance_variables.map { |var| var.to_s[1..-1].to_sym }
    # confirm all fields assigned to instance variables (check union of arrays)
    assert_empty info.keys - instance_variables
    refute_nil user.id
    # confirm refresh token from API response saved
    refute_nil user.refresh_token
  end

  def test_create_user_with_incomplete_info
    info = {
      client: test_client,
      logins: [{email: 'rubyTest@synapsepay.com', password: 'test1234', read_only: false}],
      legal_names: ['RUBY TEST USER'],
      note: 'Interesting user',
      supp_id: '122eddfgbeafrfvbbb',
      is_business: false
    }

    assert_raises(ArgumentError) { SynapsePayRest::User.create(info) }

    info_empty_arrays = {
      client: test_client,
      logins: [],
      phone_numbers: [],
      legal_names: []
    }

    assert_raises(ArgumentError) { SynapsePayRest::User.create(info_empty_arrays) }

    info_no_email = {
      client: test_client,
      logins: [{email: '', password: 'test1234', read_only: false}],
      phone_numbers: ['901.111.1111'],
      legal_names: ['RUBY TEST USER']
    }

    assert_raises(ArgumentError) { SynapsePayRest::User.create(info_no_email) }
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
    skip 'pending'
  end

  def test_all
    user_instances = SynapsePayRest::User.all(client: test_client)
    user_instance = user_instances.first
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

    new_login = {
      email: 'new@email.com',
      password: 'test1234',
      read_only: true
    }
    new_legal_name = 'Heidi'
    new_phone_number = '99999999'

    # add some info
    user.update(
      login: new_login,
      legal_name: new_legal_name,
      phone_number: new_phone_number
    )
    api_response = test_client.users.get(user_id: user.id)
    # verify that it's added
    assert api_response['logins'].any? { |login| login['email'] == new_login[:email] }
    assert_includes api_response['legal_names'], new_legal_name
    assert_includes api_response['phone_numbers'], new_phone_number

    # remove some info
    user.update(remove_login: {email: new_login[:email]}, remove_phone_number: new_phone_number)
    api_response2 = test_client.users.get(user_id: user.id)
    # verify that it's removed
    refute api_response2['logins'].any? { |login| login['email'] == new_login[:email] }
    refute_includes api_response2['phone_numbers'], new_phone_number
  end

  def test_create_base_document
    user = test_user
    base_document_info = test_base_document_base_info
    base_document_info.delete(:user)
    social_doc = test_social_document
    base_document_info[:social_documents] = [social_doc]
    user.create_base_document(base_document_info)

    refute_empty user.base_documents
    assert_equal social_doc, user.base_documents.first.social_documents.first
    assert_equal user, user.base_documents.first.user
  end

  def test_with_multiple_base_documents
    skip 'pending'
  end

  def test_fetch_nodes
    user = test_user
    user.fetch_nodes
  end

  def test_nodes_reader_method
    skip 'pending'
    user = test_user
    assert_empty user.nodes

    # TODO: add node
    assert_instance_of SynapsePayRest::Node, user.nodes.first
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

  def test_user_create_node
    skip 'pending'
  end

  def test_user_nodes
    skip 'pending'
    assert_instance_of SynapsePayRest::Node, node_list.first
  end
end
