def test_client(client_id: ENV.fetch('TEST_CLIENT_ID'),
                client_secret: ENV.fetch('TEST_CLIENT_SECRET'),
                fingerprint: 'test_fp',
                ip_address: '127.0.0.1',
                development_mode: true,
                logging: false,
                log_to: nil,
                proxy_url: nil)

  SynapsePayRest::Client.new(
    client_id: client_id,
    client_secret: client_secret,
    development_mode: development_mode,
    fingerprint: fingerprint,
    ip_address: ip_address,
    logging: logging,
    log_to: log_to,
    proxy_url: proxy_url
  )
end

def test_client_with_user(**options)
  client = test_client(options)
  user = client.users.create(payload: test_users_create_payload)
  refresh_user(client, user['_id'])
  {client: client, user: user}
end

def test_client_with_two_users(**options)
  client1 = test_client(**options)
  user1 = client1.users.create(payload: test_users_create_payload)
  refresh_user(client1, user1['_id'])
  client2 = test_client(**options)
  user2 = client2.users.create(payload: test_users_create_payload)
  refresh_user(client2, user2['_id'])
  {clients: [client1, client2], users: [user1, user2]}
end

def test_client_with_node
  test_values = test_client_with_user
  client = test_values[:client]
  user = test_values[:user]
  nodes = client.nodes.add(
    user_id: user['_id'],
    payload: test_ach_us_login_no_mfa_payload
  )['nodes']
  {client: client, user: user, node: nodes.first}
end

def test_client_with_two_nodes
  test_values = test_client_with_user
  client = test_values[:client]
  user = test_values[:user]
  nodes = client.nodes.add(
    user_id: user['_id'],
    payload: test_ach_us_login_no_mfa_payload
  )['nodes']
  nodes.push(*client.nodes.add(
    user_id: user['_id'],
    payload: test_synapse_us_payload
  )['nodes'])
  {client: client, user: user, nodes: nodes}
end

def test_client_with_two_transactions
  test_values = test_client_with_two_nodes
  client    = test_values[:client]
  user      = test_values[:user]
  nodes     = test_values[:nodes]
  from      = nodes[0]
  to        = nodes[1]
  payload1  = test_transaction_payload(from_id: from['_id'], from_type: from['type'],
                                       to_id: to['_id'], to_type: to['type'])
  payload2  = test_transaction_payload(from_id: from['_id'], from_type: from['type'],
                                       to_id: to['_id'], to_type: to['type'])
  trans1 = client.trans.create(
    user_id: user['_id'],
    node_id: from['_id'],
    payload: payload1
  )
  trans2 = client.trans.create(
    user_id: user['_id'],
    node_id: from['_id'],
    payload: payload2
  )
  {client: client, user: user, nodes: nodes, transactions: [trans1, trans2]}
end

def test_client_with_subnet
  test_values = test_client_with_user
  client = test_values[:client]
  user = test_values[:user]
  nodes = client.nodes.add(
    user_id: user['_id'],
    payload: test_deposit_us_payload
  )['nodes']

  subnet = client.subnets.create(
    user_id: user['_id'],
    node_id: nodes.first['_id'],
    payload: test_subnet_payload
    )
  {client: client, user: user, node: nodes.first, subnet: subnet}
end

def test_client_with_one_subscription
  client = test_client
  payload  = test_subscription_payload
  subscription = client.subscriptions.create(payload: payload)
  {client: client, subscription: subscription}
end

def test_client_with_instutitions
  client = test_client
  {client: client}
end
