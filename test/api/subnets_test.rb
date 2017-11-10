require 'test_helper'

class SubnetsTest < Minitest::Test
  #####
  def setup
    test_values   = test_client_with_subnet
    @client       = test_values[:client]
    @user         = test_values[:user]
    @node         = test_values[:node]
    @subnet       = test_values[:subnet]
  end

  def test_subnets_create
    subnet_payload = {
      'nickname' => 'Test Subnets'
    }
    subnet_response = @client.subnets.create(
      user_id: @user['_id'],
      node_id: @node['_id'],
      payload: subnet_payload
    )

    refute_nil subnet_response['_id']
    assert_equal subnet_response['nickname'], subnet_payload['nickname']
  end


  def test_subnets_get
    subnets_response = @client.subnets.get(
      user_id: @user['_id'],
      node_id: @node['_id']
    )

    assert_equal '0', subnets_response['error_code']
    assert_equal '200', subnets_response['http_code']
    assert_operator subnets_response['subnets_count'], :>, 0
  end

  def test_subnets_get_with_subnet_id
    subnets_response = @client.subnets.get(
      user_id: @user['_id'],
      node_id: @node['_id']
    )
    subnet_id = subnets_response['subnets'].first['_id']
    subnet_response = @client.subnets.get(
      user_id: @user['_id'],
      node_id: @node['_id'],
      subnet_id: subnet_id
    )

    assert_equal subnet_response['_id'], subnet_id
  end

end
