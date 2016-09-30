def test_client(client_id: ENV.fetch('CLIENT_ID'),
                client_secret: ENV.fetch('CLIENT_SECRET'),
                fingerprint: 'test_fp',
                ip_address: '127.0.0.1',
                development_mode: true,
                user_id: nil,
                logging: false)
  options = {
    'client_id'        => client_id,
    'client_secret'    => client_secret,
    'fingerprint'      => fingerprint,
    'ip_address'       => ip_address,
    'development_mode' => development_mode
  }

  SynapsePayRest::Client.new(options: options, user_id: user_id, logging: logging)
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
  refresh_user(client, client.user_id)
  client.nodes.add(payload: test_ach_us_login_no_mfa_payload)
  client
end

def test_client_with_two_nodes
  client = test_client_with_user
  refresh_user(client, client.user_id)
  client.nodes.add(payload: test_ach_us_login_no_mfa_payload)
  client.nodes.add(payload: test_synapse_us_payload)
  client
end
