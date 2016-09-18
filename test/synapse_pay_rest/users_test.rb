require 'test_helper'

class UsersTest < Minitest::Test
  def test_users_create
    created_user = test_user

    refute_nil created_user['_id']
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
    user = test_client.users.get(user_id: test_user['id'])

    refute_nil user
  end
end
