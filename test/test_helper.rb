$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapse_pay_rest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'dotenv'
Dotenv.load

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

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

def test_user
  payload = {
    "logins" =>  [
      {
        "email" =>  "rubyTest@synapsepay.com",
        "password" =>  "test1234",
        "read_only" => false
      }
    ],
    "phone_numbers" =>  [
      "901.111.1111"
    ],
    "legal_names" =>  [
      "RUBY TEST USER"
    ],
    "extra" =>  {
      "note" =>  "Interesting user",
      "supp_id" =>  "122eddfgbeafrfvbbb",
      "is_business" =>  false
    }
  }
  test_client.users.create(payload: payload)
end

def authenticated_client
  options = {
    'fingerprint' => ENV.fetch('FINGERPRINT'),
    'client_id' => ENV.fetch('CLIENT_ID'),
    'client_secret' => ENV.fetch('CLIENT_SECRET'),
    'ip_address' => ENV.fetch('IP_ADDRESS'),
    'development_mode' => true
  }

  SynapsePayRest::Client.new(options: options, user_id: test_user['_id'])
end
