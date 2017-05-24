require 'test_helper'

class SubscriptionsTest < Minitest::Test
  def setup
    test_values   = test_client_with_one_subscription
    @client       = test_values[:client]
    @subscription = test_values[:subscription]
  end

  def test_subscriptions_create
    subscription_payload = {
      'url' => "http://localhost:3000",
      'scope' => ['USERS|POST']
    }
    subscription_response = @client.subscriptions.create(
      payload: subscription_payload
    )

    refute_nil subscription_response['_id']
    assert_equal subscription_response['is_active'], true
    assert_equal subscription_response['scope'], subscription_payload['scope']
    assert_equal subscription_response['url'], subscription_payload['url']
  end

  def test_subscriptions_get
    subscriptions_response = @client.subscriptions.get()

    assert_equal '0', subscriptions_response['error_code']
    assert_equal '200', subscriptions_response['http_code']
    assert_operator subscriptions_response['subscriptions_count'], :>, 0
  end

  def test_subscriptions_get_with_subscription_id
    subscriptions_response = @client.subscriptions.get(
      subscription_id: @subscription['_id']
    )
    subscription_id = subscriptions_response['_id']
    
    assert_equal subscription_id, @subscription['_id']
  end

  def test_subscriptions_update
    payload = {'url' => "http://test.com.update"}
    
    update_response = @client.subscriptions.update(
      subscription_id: @subscription['_id'],
      payload: payload
    )
    refute_nil update_response['_id']
    is_active = update_response['url']
    assert_match "http://test.com.update", is_active
  end

end
