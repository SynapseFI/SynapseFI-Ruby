def test_subscription_create_args(url:, scope:)
  {
    url: url,
    scope: scope
  }
end

def test_subscription(url:, scope:, **options)
    args = test_subscription_create_args(url: url, scope: scope, **options)
    SynapsePayRest::Subscription.create(args)
end
