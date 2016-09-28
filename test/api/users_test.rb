require 'test_helper'

class UsersTest < Minitest::Test
  def setup
    @client = test_client_with_user
    @user = oauth_user(@client, @client.user_id)
  end

  def test_users_create
    payload_created_user = test_client.users.create(payload: test_user_payload1)

    refute_nil payload_created_user['_id']
  end

  def test_users_get
    users = @client.users.get

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert users['success']
    refute_nil users['users']
  end

  def test_users_get_with_pagination
    users = test_client.users.get(page: 2, per_page: 3)

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert_equal 2, users['page']
    assert_equal 3, users['users'].length
  end

  def test_users_get_with_query
    users = test_client.users.get(query: 'Doe')

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert_operator users['users'].length, :>, 0
  end

  def test_users_get_with_user_id
    user = @client.users.get(user_id: @client.user_id)
    refute_nil user['_id']
  end

  def test_users_update
    payload = {
      'refresh_token' => @user['refresh_token'],
      'update' => {
        'login' => {
          'email' => 'test2ruby@email.com',
          'password' => 'test1234',
          'read_only' => true
        },
        'phone_number' => '9019411111',
        'legal_name' => 'Some new name'
      }
    }

    response = @client.users.update(payload: payload)
    refute_nil response['_id']
  end

  def test_add_doc_successful
    payload = {
      'doc' => {
        'birth_day' => 4,
        'birth_month' => 2,
        'birth_year' => 1940,
        'name_first' => 'John',
        'name_last' => 'Doe',
        'address_street1' => '1 Infinite Loop',
        'address_postal_code' => '95014',
        'address_country_code' => 'US',
        'document_value' => '2222',
        'document_type' => 'SSN'
      }
    }
    response = @client.users.add_doc(payload: payload)

    refute_nil response['_id']
  end

  def test_add_doc_with_answer_kba
    add_doc_payload = {
      'doc' => {
        'birth_day' => 4,
        'birth_month' => 2,
        'birth_year' => 1940,
        'name_first' => 'John',
        'name_last' => 'Snow',
        'address_street1' => '1 Infinite Loop',
        'address_postal_code' => '95014',
        'address_country_code' => 'US',
        'document_value' => '3333',
        'document_type' => 'SSN'
      }
    }
    add_doc_response = @client.users.add_doc(payload: add_doc_payload)

    assert_equal add_doc_response['error_code'], '10'
    assert_equal add_doc_response['http_code'], '202'

    kba_payload = {
      'doc' => {
        'question_set_id' => add_doc_response['question_set']['id'],
        'answers' => [
          { 'question_id' =>  1, 'answer_id' => 1 },
          { 'question_id' =>  2, 'answer_id' => 1 },
          { 'question_id' =>  3, 'answer_id' => 1 },
          { 'question_id' =>  4, 'answer_id' => 1 },
          { 'question_id' =>  5, 'answer_id' => 2 }
        ]
      }
    }
    kba_response = @client.users.answer_kba(payload: kba_payload)
    ssn_field = kba_response['documents'][0]['virtual_docs'].find do |doc|
      doc['document_type'] == 'SSN'
    end

    assert_nil ssn_field['meta']
  end

  def test_attach_file
    response = @client.users.attach_file(file_path: fixture_path('id.png'))
    refute_nil response['_id']
  end

  def test_add_documents_via_base_document2
    govt_id_attachment = @client.users.encode_attachment(file_path: fixture_path('id.png'))
    selfie_attachment = @client.users.encode_attachment(file_path: fixture_path('id.png'))

    add_documents_payload = {
        "documents" => [{
            "email" => "test@test.com",
            "phone_number" => "901-942-8167",
            "ip" => "12134323",
            "name" => "Charlie Brown",
            "alias" => "Woof Woof",
            "entity_type" => "M",
            "entity_scope" => "Arts & Entertainment",
            "day" => 2,
            "month" => 5,
            "year" => 2009,
            "address_street" => "Some Farm",
            "address_city" => "SF",
            "address_subdivision" => "CA",
            "address_postal_code" => "94114",
            "address_country_code" => "US",
            "virtual_docs" => [{
                "document_value" => "111-111-2222",
                "document_type" => "SSN"
            }],
            "physical_docs" => [{
                "document_value" => govt_id_attachment,
                "document_type" => "GOVT_ID"
            },
            {
                "document_value" => selfie_attachment,
                "document_type" => "SELFIE"
            }],
            "social_docs" => [{
                "document_value" => "https://www.facebook.com/sankaet",
                "document_type" => "FACEBOOK"
            }]
        }]
    }

    response = @client.users.update(payload: add_documents_payload)
    base_document = response['documents'].last

    assert_operator base_document.length, :>=, 4
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'GOVT_ID' }
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'SELFIE' }
    assert base_document['virtual_docs'].any? { |doc| doc['document_type'] == 'SSN' }
    assert base_document['social_docs'].any? { |doc| doc['document_type'] == 'FACEBOOK' }
  end

  def test_add_documents_via_base_document2_with_kba
    govt_id_attachment = @client.users.encode_attachment(file_path: fixture_path('id.png'))
    selfie_attachment = @client.users.encode_attachment(file_path: fixture_path('id.png'))

    add_documents_payload = {
        'documents' => [{
            'email' => 'test2@test.com',
            'phone_number' => '901-942-8167',
            'ip' => '12134323',
            'name' => 'Snoopie',
            'alias' => 'Meow',
            'entity_type' => 'M',
            'entity_scope' => 'Arts & Entertainment',
            'day' => 2,
            'month' => 5,
            'year' => 2009,
            'address_street' => 'Some Farm',
            'address_city' => 'SF',
            'address_subdivision' => 'CA',
            'address_postal_code' => '94114',
            'address_country_code' => 'US',
            'virtual_docs' => [{
                'document_value' => '111-111-3333',
                'document_type' => 'SSN'
            }],
            'physical_docs' => [{
                'document_value' => govt_id_attachment,
                'document_type' => 'GOVT_ID'
            },
            {
                'document_value' => selfie_attachment,
                'document_type' => 'SELFIE'
            }],
            'social_docs' => [{
                'document_value' => 'https://www.facebook.com/sankaet',
                'document_type' => 'FACEBOOK'
            }]
        }]
    }

    add_docs_response = @client.users.update(payload: add_documents_payload)
    base_document = add_docs_response['documents'].last

    assert_operator base_document.length, :>=, 4
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'GOVT_ID' }
    assert base_document['physical_docs'].any? { |doc| doc['document_type'] == 'SELFIE' }
    assert base_document['virtual_docs'].any? { |doc| doc['document_type'] == 'SSN' }
    assert base_document['social_docs'].any? { |doc| doc['document_type'] == 'FACEBOOK' }

    ssn = base_document['virtual_docs'].find { |doc| doc['document_type'] == 'SSN' && doc['status'] == 'SUBMITTED|MFA_PENDING'}
    assert_equal 'SUBMITTED|MFA_PENDING', ssn['status']

    kba_payload = {
      'documents' => [{
        'id' => base_document['id'],
        'virtual_docs' => [{
          'id' => ssn['id'],
          'meta' => {
            'question_set' => {
              'answers' => [
                { 'question_id' => 1, 'answer_id' => 1 },
                { 'question_id' => 2, 'answer_id' => 1 },
                { 'question_id' => 3, 'answer_id' => 1 },
                { 'question_id' => 4, 'answer_id' => 1 },
                { 'question_id' => 5, 'answer_id' => 1 }
              ]
            }
          }
        }]
      }]
    }
    kba_response = @client.users.update(payload: kba_payload)
    validated_ssn = kba_response['documents'].last['virtual_docs'].find { |doc| doc['id'] == ssn['id']}

    assert_equal 'SUBMITTED|VALID', validated_ssn['status']
  end
end
