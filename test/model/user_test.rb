require 'test_helper'

class UserTest < Minitest::Test
  def setup
    @user = test_user
  end

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
    user = test_user_with_cip_document_with_three_documents
    user_instance = SynapsePayRest::User.find(client: test_client, id: user.id)
    user_data_from_api = test_client.users.get(user_id: user.id)

    assert_instance_of SynapsePayRest::User, user_instance
    assert_equal user_data_from_api['_id'], user_instance.id
    assert_equal user_data_from_api['logins'], user_instance.logins
    # confirm documents survive being submitted and fetched
    refute_nil user_instance.cip_document
    refute_nil user_instance.cip_document.id
    refute_empty user_instance.cip_document.social_documents
    refute_empty user_instance.cip_document.physical_documents
    refute_empty user_instance.cip_document.virtual_documents
    refute_nil user_instance.cip_document.virtual_documents.first.id
    # 3 + 1 because the phone number from base doc is auto-added to documents
    assert_equal 4, user_instance.cip_document.documents.count
  end

  def test_find_user_with_non_existent_id_raises_error
    skip 'pending'
  end

  def test_all
    user_instances = SynapsePayRest::User.all(client: test_client)
    user_instance = user_instances.first
    assert_instance_of Array, user_instances
    assert_equal user_instances.length, 15
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
    assert_equal page.length, 10
  end

  def test_search
    results = SynapsePayRest::User.search(client: test_client, query: 'Betty')
    assert results.any? { |user| user.legal_names.include? 'Betty White' }

    results2 = SynapsePayRest::User.search(client: test_client, query: 'Frank')
    assert_empty results2
  end

  def test_search_with_page_and_per_page
    skip 'pending'
  end

  def test_update
    new_login = {
      email: 'new@email.com',
      password: 'test1234',
      read_only: true
    }
    new_legal_name = 'Heidi'
    new_phone_number = '99999999'

    # add some info
    @user.update(
      login: new_login,
      legal_name: new_legal_name,
      phone_number: new_phone_number
    )
    api_response = test_client.users.get(user_id: @user.id)
    # verify that it's added
    assert api_response['logins'].any? { |login| login['email'] == new_login[:email] }
    assert_includes api_response['legal_names'], new_legal_name
    assert_includes api_response['phone_numbers'], new_phone_number

    # remove some info
    @user.update(remove_login: {email: new_login[:email]}, remove_phone_number: new_phone_number)
    api_response2 = test_client.users.get(user_id: @user.id)
    # verify that it's removed
    refute api_response2['logins'].any? { |login| login['email'] == new_login[:email] }
    refute_includes api_response2['phone_numbers'], new_phone_number
  end

  def test_create_cip_document
    social_doc_info = {
      category: :social,
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/marcopolo'
    }
    social_doc = SynapsePayRest::Document.new(social_doc_info)
    cip_info = {
      email: 'piper@pie.com',
      phone_number: '4444444',
      ip: '127002',
      name: 'Piper',
      alias: 'Hallowell',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 1,
      birth_month: 2,
      birth_year: 1933,
      address_street: '333 14th St',
      address_city: 'SF',
      address_subdivision: 'CA',
      address_postal_code: '94114',
      address_country_code: 'US',
      documents: [social_doc]
    }
    @user.create_cip_document(cip_info)
    cip_doc = @user.cip_document

    refute_nil @user.cip_document
    assert_equal cip_doc, @user.cip_document
    assert_equal cip_doc.user, @user
  end

  def test_with_multiple_cip_docs
    skip 'pending'
  end

  def test_user_create_node
    skip 'pending'
    @user.create_node
  end

  def test_user_nodes
    skip 'pending'
    assert_instance_of SynapsePayRest::Node, node_list.first
  end

  def test_user_find_node
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
