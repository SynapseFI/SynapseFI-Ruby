require 'test_helper'

class UsersTest < Minitest::Test
  def setup
    test_values = test_client_with_user
    @client     = test_values[:client]
    @user       = test_values[:user]
  end

  def test_users_create
    response = @client.users.create(payload: test_users_create_payload)
    refute_nil response['_id']
  end

  def test_users_get
    response = @client.users.get

    assert_equal '200', response['http_code']
    assert_equal '0', response['error_code']
    assert response['success']
    refute_nil response['users']
  end

  def test_users_get_with_pagination
    response = @client.users.get(page: 2, per_page: 3)

    assert_equal '200', response['http_code']
    assert_equal '0', response['error_code']
    assert_equal 2, response['page']
    assert_equal 3, response['users'].length
  end

  def test_users_get_with_query
    response = @client.users.get(query: '.com')

    assert_equal '200', response['http_code']
    assert_equal '0', response['error_code']
    assert_operator response['users'].length, :>, 0
  end

  def test_users_get_with_user_id
    response = @client.users.get(user_id: @user['_id'])
    refute_nil response['_id']
  end

  def test_users_update
    payload = test_users_update_payload(refresh_token: @user['refresh_token'])
    response = @client.users.update(user_id: @user['_id'], payload: payload)
    refute_nil response['_id']
  end

  def test_add_doc_kyc1_successful
    payload = test_add_doc_kyc1_payload(document_value: '2222')
    response = @client.users.add_doc(user_id: @user['_id'], payload: payload)

    refute_nil response['_id']
  end

  def test_add_doc_kyc1_with_correct_answer_kba
    skip 'deprecated'
    add_doc_response = @client.users.add_doc(payload: test_add_doc_kyc1_payload(document_value: '3333'))

    assert_equal add_doc_response['error_code'], '10'
    assert_equal add_doc_response['http_code'], '202'

    question_set_id = add_doc_response['question_set']['id']
    payload = test_kba_kyc1_payload(question_set_id: question_set_id)
    kba_response = @client.users.answer_kba(
      user_id: @user['_id'],
      payload: payload
    )
    ssn_field = kba_response['documents'][0]['virtual_docs'].find do |doc|
      doc['document_type'] == 'SSN'
    end

    assert_nil ssn_field['meta']
  end

  def test_add_documents_via_kyc2
    response = @client.users.update(
      user_id: @user['_id'],
      payload: test_add_documents_kyc2_payload
    )
    base_document = response['documents'].last

    assert_operator base_document.length, :>=, 4
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'GOVT_ID' }
    assert base_document['virtual_docs'].any? { |doc| doc['document_type'] == 'SSN' }
    assert base_document['social_docs'].any? { |doc| doc['document_type'] == 'FACEBOOK' }
  end

  def test_add_documents_via_kyc2_with_kba
    skip 'deprecated'
    add_docs_response = @client.users.update(payload: test_add_documents_kyc2_payload(virtual_docs: [test_kba_ssn_hash]))
    base_document = add_docs_response['documents'].last

    assert_operator base_document.length, :>=, 4
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'GOVT_ID' }
    assert base_document['virtual_docs'].any? { |doc| doc['document_type'] == 'SSN' }
    assert base_document['social_docs'].any? { |doc| doc['document_type'] == 'FACEBOOK' }

    ssn = base_document['virtual_docs'].find { |doc| doc['document_type'] == 'SSN' && doc['status'] == 'SUBMITTED|MFA_PENDING'}
    assert_equal 'SUBMITTED|MFA_PENDING', ssn['status']

    kba_payload = test_kba_kyc_2_payload(
      base_document_id: base_document['id'],
      document_id: ssn['id']
    )
    kba_response = @client.users.update(
      user_id: @user['_id'],
      payload: kba_payload
    )
    validated_ssn = kba_response['documents'].last['virtual_docs'].find { |doc| doc['id'] == ssn['id']}

    assert_equal 'SUBMITTED|VALID', validated_ssn['status']
  end
end
