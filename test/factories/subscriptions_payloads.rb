# create different number of subscription for different tests
def test_subscription_payload(url: "http://localhost:3000", scope: ['USERS|POST'])
  {
    'url' => url,
    'scope' => scope
  }
end