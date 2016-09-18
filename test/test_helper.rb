$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapse_pay_rest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'dotenv'
Dotenv.load

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

TEST_ROOT = File.dirname(File.expand_path('.', __FILE__))

def fixture_path(file_name)
  "#{TEST_ROOT}/fixtures/#{file_name}"
end

def test_client
  options = {
    'fingerprint' => ENV.fetch('FINGERPRINT'),
    'client_id' => ENV.fetch('CLIENT_ID'),
    'client_secret' => ENV.fetch('CLIENT_SECRET'),
    'ip_address' => ENV.fetch('IP_ADDRESS'),
    'development_mode' => true
  }

  SynapsePayRest::Client.new(options: options)
end

def client_with_user
  options = {
    'fingerprint' => ENV.fetch('FINGERPRINT'),
    'client_id' => ENV.fetch('CLIENT_ID'),
    'client_secret' => ENV.fetch('CLIENT_SECRET'),
    'ip_address' => ENV.fetch('IP_ADDRESS'),
    'development_mode' => true
  }

  SynapsePayRest::Client.new(options: options, user_id: ENV.fetch('USER_ID'))
end

def client_with_node
  client = client_with_user
  user = oauth_user(client, ENV.fetch('USER_ID'))

  payload = {
      'type' => 'ACH-US',
      'info' => {
          'bank_id' => 'synapse_nomfa',
          'bank_pw' => 'test1234',
          'bank_name' => 'fake'
      }
  }
  client.nodes.add(payload: payload)
  client
end

def test_user
  payload = {
    'logins' =>  [
      {
        'email' =>  'rubyTest@synapsepay.com',
        'password' =>  'test1234',
        'read_only' => false
      }
    ],
    'phone_numbers' =>  [
      '901.111.1111'
    ],
    'legal_names' =>  [
      'RUBY TEST USER'
    ],
    'extra' =>  {
      'note' =>  'Interesting user',
      'supp_id' =>  '122eddfgbeafrfvbbb',
      'is_business' =>  false
    }
  }
  test_client.users.create(payload: payload)
end

def oauth_user(client, user_id)
    user = client.users.get(user_id: user_id)
    oauth = client.users.refresh(payload: {
      'refresh_token' => user['refresh_token']
    })
    user
end

