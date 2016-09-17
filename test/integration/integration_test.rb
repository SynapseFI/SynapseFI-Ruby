require 'test_helper'

class IntegrationTest < Minitest::Test
  def test_users_update
    client = authenticated_client
    user_id = client.client.user_id
    user = test_client.users.get(user_id: user_id)

    payload = {
      "refresh_token" => user['refresh_token'],
      "update" => {
        "login" => {
          "email" => "test2ruby@email.com",
          "password" => "test1234",
          "read_only" => true
        },
        "phone_number" => "9019411111",
        "legal_name" => "Some new name"
      }
    }
    
    response = client.users.update(payload: payload)
    refute_nil response['_id']
  end

  def test_add_doc_successful
    client = authenticated_client
    user_id = client.client.user_id
    user = test_client.users.get(user_id: user_id)
    oauth = client.users.refresh(payload: {
      'refresh_token' => user['refresh_token']
    })

    payload = {
      "doc" => {
        "birth_day" => 4,
        "birth_month" => 2,
        "birth_year" => 1940,
        "name_first" => "John",
        "name_last" => "Doe",
        "address_street1" => "1 Infinite Loop",
        "address_postal_code" => "95014",
        "address_country_code" => "US",
        "document_value" => "2222",
        "document_type" => "SSN"
      }
    }
    response = client.users.add_doc(payload: payload)
    refute_nil response['_id']
  end

  def test_add_doc_with_answer_kba
    client = authenticated_client
    user_id = client.client.user_id
    user = test_client.users.get(user_id: user_id)
    oauth = client.users.refresh(payload: {
      'refresh_token' => user['refresh_token']
    })
    payload = {
      "doc" => {
        "birth_day" => 4,
        "birth_month" => 2,
        "birth_year" => 1940,
        "name_first" => "John",
        "name_last" => "Snow",
        "address_street1" => "1 Infinite Loop",
        "address_postal_code" => "95014",
        "address_country_code" => "US",
        "document_value" => "3333",
        "document_type" => "SSN"
      }
    }

    response = client.users.add_doc(payload: payload)
    assert_equal response['error_code'], '10'
    assert_equal response['http_code'], '202'

    kba_payload = {
      "doc" => {
        "question_set_id" => response['question_set']['id'],
        "answers" => [
          { "question_id" =>  1, "answer_id" => 1 },
          { "question_id" =>  2, "answer_id" => 1 },
          { "question_id" =>  3, "answer_id" => 1 },
          { "question_id" =>  4, "answer_id" => 1 },
          { "question_id" =>  5, "answer_id" => 2 }
        ]
      }
    }

    kba_response = client.users.answer_kba(payload: kba_payload)
    ssn_field = kba_response['documents'][-1]['virtual_docs'].find {|doc| doc['document_type'] == 'SSN'}
    assert_nil ssn_field['meta']
  end

  def test_attach_file
  end

  def test_attach_file_with_file_type
  end
end