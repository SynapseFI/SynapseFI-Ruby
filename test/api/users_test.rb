require 'test_helper'

class UsersTest < Minitest::Test
  def setup
    @client = client_with_user
    @user = oauth_user(@client, ENV.fetch('USER_ID'))
  end

  def test_users_create
    payload = {
      'logins' => [
        {
          'email' => 'rubyTest@synapsepay.com',
          'password' => 'test1234',
          'read_only' => false
        }
      ],
      'phone_numbers' => [
        '901.111.1111'
      ],
      'legal_names' => [
        'RUBY TEST USER'
      ],
      'extra' => {
        'note' => 'Interesting user',
        'supp_id' => '122eddfgbeafrfvbbb',
        'is_business' => false
      }
    }
    payload_created_user = test_client.users.create(payload: payload)

    refute_nil payload_created_user['_id']
  end

  def test_users_get
    users = test_client.users.get

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert users['success']
    refute_nil users['users']
  end

  def test_users_get_with_pagination
    users = test_client.users.get(options: {page: 2, per_page: 3})

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert_equal 2, users['page']
    assert_equal 3, users['users'].length
  end

  def test_users_get_with_query
    users = test_client.users.get(options: {query: 'Doe'})

    assert_equal '200', users['http_code']
    assert_equal '0', users['error_code']
    assert_operator users['users'].length, :>, 0
  end

  def test_users_get_with_user_id
    user = test_client.users.get(user_id: test_user['_id'])
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
    ssn_field = kba_response['documents'][0]['virtual_docs'].find {|doc| doc['document_type'] == 'SSN'}

    assert_nil ssn_field['meta']
  end

  def test_attach_file
    response = @client.users.attach_file(file_path: fixture_path('id.png'))
    refute_nil response['_id']
  end
end
