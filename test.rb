require './lib/synapse_pay_rest'

args = {
  # synapse client_id
  client_id:        'client_id_2bb1e412edd311e6bd04e285d6015267',
  # synapse client_secret
  client_secret:    'client_secret_2bb1e714edd311e6bd04e285d6015267',
  # a hashed value, either unique to user or static for app
  fingerprint:      'e83cf6ddcf778e37bfe3d48fc78a6502062fc1030449628c699ef3c4ffa6f9a2000b8acc3c4c0addd8013285bb52c89e5267b628ca02fa84a6d71fe186b7cd5d',
  # the user's IP
  ip_address:       '127.0.0.1',
  # (optional) requests go to sandbox endpoints if true
  development_mode: true,
  # (optional) if true logs requests to stdout
  logging:          false,
  # (optional) file path to write logs to
  log_to:           nil
}

client = SynapsePayRest::Client.new(args)

user = SynapsePayRest::User.find(client: client, id: '592759a50abfb20022d341a8', full_dehydrate: 'yes')

# node = SynapsePayRest::Node.find(user: user, id: '58b0963e7e088700211fe144', full_dehydrate: 'no')

puts user.inspect