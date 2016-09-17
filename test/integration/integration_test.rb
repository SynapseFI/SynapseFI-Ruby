require 'test_helper'

class IntegrationTest < Minitest::Test
  def setup
    @client = authenticated_client
    @user = oauth_user(@client, ENV.fetch('USER_ID'))
  end

  def test_users_update
    payload = {
      "refresh_token" => @user['refresh_token'],
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
    
    response = @client.users.update(payload: payload)
    refute_nil response['_id']
  end

  def test_add_doc_successful
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
    response = @client.users.add_doc(payload: payload)

    refute_nil response['_id']
  end

  def test_add_doc_with_answer_kba
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
    response = @client.users.add_doc(payload: payload)

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
    kba_response = @client.users.answer_kba(payload: kba_payload)
    ssn_field = kba_response['documents'][-1]['virtual_docs'].find {|doc| doc['document_type'] == 'SSN'}

    assert_nil ssn_field['meta']
  end

  def test_attach_file
    response = @client.users.attach_file(file_path: fixture_path('id.png'))
    
    refute_nil response['_id']
  end
end