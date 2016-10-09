def test_client(client_id: ENV.fetch('CLIENT_ID'),
                client_secret: ENV.fetch('CLIENT_SECRET'),
                fingerprint: 'test_fp',
                ip_address: '127.0.0.1',
                user_id: nil,
                development_mode: true,
                logging: false,
                log_to: nil)

  SynapsePayRest::Client.new(
    client_id: client_id,
    client_secret: client_secret,
    development_mode: development_mode,
    user_id: user_id,
    fingerprint: fingerprint,
    ip_address: ip_address,
    logging: logging,
    log_to: log_to
  )
end

def test_client_with_user(**options)
  user_response = test_client.users.create(payload: test_users_create_payload)
  test_client(user_id: user_response['_id'], **options)
end

def test_client_with_two_users(**options)
  user_response1 = test_client(**options).users.create(payload: test_users_create_payload)
  user_response2 = test_client(**options).users.create(payload: test_users_create_payload)
  test_client(**options, user_id: user_response1['_id'])
end

def test_client_with_node
  client = test_client_with_user
  refresh_user(client, client.client.user_id)
  client.nodes.add(payload: test_ach_us_login_no_mfa_payload)
  client
end

def test_client_with_two_nodes
  client = test_client_with_user
  refresh_user(client, client.client.user_id)
  client.nodes.add(payload: test_ach_us_login_no_mfa_payload)
  client.nodes.add(payload: test_synapse_us_payload)
  client
end

def test_client_with_two_transactions
  client    = test_client_with_two_nodes
  nodes     = client.nodes.get['nodes']
  from      = nodes.first
  to        = nodes.last
  payload1  = test_transaction_payload(from_id: from['_id'], from_type: from['type'],
                                       to_id: to['_id'], to_type: to['type'])
  payload2  = test_transaction_payload(from_id: from['_id'], from_type: from['type'],
                                       to_id: to['_id'], to_type: to['type'])

  client.trans.create(node_id: from['_id'], payload: payload1)
  client.trans.create(node_id: from['_id'], payload: payload2)
  client
end
