require 'test_helper'

class UserTest < Minitest::Test
  def setup
    @user = SynapsePayRest::User.new(
      client: test_client,
      logins: [{email: 'betty@white.com'}],
      phone_numbers: [415-555-5555],
      legal_names: ['Betty White']
    )
  end

  def test_initialize_user_with_existing_user_id
    user_data_from_api = test_client.users.get(user_id: ENV.fetch('USER_ID'))
    assert_equal @user.id, user_data_from_api['_id']
    assert_equal @user.logins, user_data_from_api['logins']
    assert_equal @user.legal_names, user_data_from_api['legal_names']
    refute_nil @user.refresh_token
  end

  def test_initialize_user_with_new_info
    info = {
      client: test_client,
      logins: [{email: 'rubyTest@synapsepay.com', password: 'test1234'}],
      read_only: false,
      phone_numbers: ['901.111.1111'],
      legal_names: ['RUBY TEST USER'],
      note: 'Interesting user',
      supp_id: '122eddfgbeafrfvbbb',
      is_business: false
    }
    user = SynapsePayRest::User.new(info)
    # shift @ off from instance var names
    instance_variables = user.instance_variables.map { |var| var.to_s[1..-1].to_sym }
    # confirm all fields assigned to instance variables (check union of arrays)
    assert_empty info.keys - instance_variables
    refute_nil user.id
    refute_nil user.refresh_token
  end

  def test_initialize_user_with_incomplete_info
    info = {
      password: 'test1234',
      read_only: false,
      note: 'Interesting user',
      supp_id: '122eddfgbeafrfvbbb',
      is_business: false
    }

    assert_raises(ArgumentError) { SynapsePayRest::User.new(info) }
  end

  # class methods

  def test_find
    user_data_from_api = test_client.users.get(user_id: ENV.fetch('USER_ID'))
    user_instance = SynapsePayRest::User.find(
      client: test_client,
      id: ENV.fetch('USER_ID')
    )

    assert_instance_of SynapsePayRest::User, user_instance
    assert_equal user_data_from_api['_id'], user_instance.id
    assert_equal user_data_from_api['logins'], user_instance.logins
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
    api_response = test_client.users.get(user_id: ENV.fetch('USER_ID'))
    # verify that it's added
    assert api_response['logins'].any? { |login| login['email'] == new_login[:email] }
    assert_includes api_response['legal_names'], new_legal_name
    assert_includes api_response['phone_numbers'], new_phone_number

    # remove some info
    @user.update(remove_login: {email: new_login[:email]}, remove_phone_number: new_phone_number)
    api_response2 = test_client.users.get(user_id: ENV.fetch('USER_ID'))
    # verify that it's removed
    refute api_response2['logins'].any? { |login| login['email'] == new_login[:email] }
    refute_includes api_response2['phone_numbers'], new_phone_number
  end

  def test_documents_can_be_read
    refute_empty @user.documents
    assert_instance_of SynapsePayRest::Document, @user.documents.first
  end

  def test_add_documents
    social_doc_info = {
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
      category: :social,
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
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
      category: :virtual,
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
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
      category: :physical,
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    social_doc = SynapsePayRest::Document.new(social_doc_info)
    virtual_doc = SynapsePayRest::Document.new(virtual_doc_info)
    physical_doc = SynapsePayRest::Document.new(physical_doc_info)
    @user.add_documents(virtual_doc, physical_doc, social_doc)

    assert_includes @user.documents, social_doc
    assert_includes @user.documents, virtual_doc
    assert_includes @user.documents, physical_doc

    # verify with API that document was added
    response_docs = test_client.users.get(user_id: @user.id)['documents'].first
    assert response_docs['social_docs'].any? { |doc| doc['document_type'] == social_doc.type }
    assert response_docs['virtual_docs'].any? { |doc| doc['document_type'] == virtual_doc.type }
    assert response_docs['physical_docs'].any? { |doc| doc['document_type'] == physical_doc.type }
  end

  # def test_update_document
  # end

  # nodes

  # def test_user_create_node
  #   node = SynapsePayRest::Node.new()
  #   @user.create
  # end

  # def test_user_nodes
  #   assert_instance_of SynapsePayRest::Node, node_list.first
  # end
end
