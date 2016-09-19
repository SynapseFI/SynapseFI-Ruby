require 'test_helper'

class UsersTest < Minitest::Test
  def test_users_create_with_payload
    payload = {
      'logins' =>  [
        {
          'email' =>  'rubyTest@synapsepay.com',
          'password' =>  'test1234',
          'read_only' => false
        }
      ],
      'phone_numbers' =>  [
        '901.111.1111'
      ],
      'legal_names' =>  [
        'RUBY TEST USER'
      ],
      'extra' =>  {
        'note' =>  'Interesting user',
        'supp_id' =>  '122eddfgbeafrfvbbb',
        'is_business' =>  false
      }
    }
    payload_created_user = test_client.users.create(payload: payload)
    refute_nil payload_created_user['_id']
  end

  def test_users_create_with_kwargs
    args = {
      email: 'rubyTest@synapsepay.com',
      password: 'test1234',
      read_only: false,
      phone_numbers: ['901.111.1111'],
      legal_names: ['RUBY TEST USER'],
      note: 'Interesting user',
      supp_id: '122eddfgbeafrfvbbb',
      is_business: false
    }

    p kwargs_created_user = test_client.users.create(args)
    refute_nil kwargs_created_user['_id']
  end

  def test_users_all
    users_response = test_client.users.all
    assert_operator search_response_match.length, :>, 0

    p per_page_response = test_client.users.all(per_page: 5)
    assert_equal per_page_response.length, 5
  end

  def test_users_find
    user_response = test_client.users.find(user_id: ENV.fetch('USER_ID'))

    refute_nil user_response['_id']
  end

  def test_users_search
    search_response_match = test_client.users.search(query: 'test')
    assert_operator search_response_match.length, :>, 0

    search_response_non_match = test_client.users.search(query: 'adkl;ahkdsflasdfk;')
    assert_equal search_response_non_match.length, 0

    search_response_match_3 = test_client.users.search(query: 'test', per_page: 3)
    assert_equal search_response_match_3.length, 3
  end

  # ##############
  # base API calls
  # ##############

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
    user = test_client.users.get(user_id: test_user['id'])

    refute_nil user['_id']
  end
end
