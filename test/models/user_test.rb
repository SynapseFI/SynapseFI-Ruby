require 'test_helper'

class UserTest < Minitest::Test
  def setup
    @user = SynapsePayRest::User.new(client: test_client, id: ENV.fetch('USER_ID'))
  end

  def test_initialize_user_with_existing_user_id
    user_data_from_api = test_client.users.get(user_id: ENV.fetch('USER_ID'))
    assert_equal @user.id, user_data_from_api['_id']
    assert_equal @user.logins, user_data_from_api['logins']
    assert_equal @user.legal_names, user_data_from_api['legal_names']
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
    login = {
      email: 'test2@email.com',
      password: 'test1234',
      read_only: true
    }
  end

  # nodes

  # def test_user_create_node
  #   node = SynapsePayRest::Node.new()
  #   @user.create
  # end

  # def test_user_nodes
  #   assert_instance_of SynapsePayRest::Node, node_list.first
  # end
end
