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
    'client_id' => ENV.fetch('CLIENT_ID'),
    'client_secret' => ENV.fetch('CLIENT_SECRET'),
    'fingerprint' => 'test_fp',
    'ip_address' => '127.0.0.1',
    'development_mode' => true
  }

  SynapsePayRest::Client.new(options: options)
end

# TODO: can definitely optimize these to remove GET and just pass id info
def client_with_user
  payload = {
    'logins' => [
      {
        'email' => 'rubyTest@synapsepay.com',
        'password' =>  'test1234',
        'read_only' => false
      }
    ],
    'phone_numbers' => [
      '901.111.1111'
    ],
    'legal_names' => [
      'RUBY TEST USER'
    ],
    'extra' => {
      'note' => 'Interesting user',
      'supp_id' => '122eddfgbeafrfvbbb',
      'is_business' => false
    }
  }
  user_response = test_client.users.create(payload: payload)
  client = test_client
  client.user_id = user_response['_id']
  client.http_client.user_id = user_response['_id']
  client.http_client.user_id = user_response['_id']
  client
end

# create different number of nodes for different tests
def client_with_nodes
  client = client_with_user
  user = oauth_user(client, client.user_id)

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

# create different number of users for different tests
def client_with_transactions
  client    = client_with_nodes
  nodes     = client.nodes.get['nodes']
  from_node = nodes.first
  to_node   = nodes.last

  transaction_payload1 = {
    'to' => {
      'type' => 'ACH-US',
      'id' => to_node['_id']
    },
    'amount' => {
      'amount' => 22,
      'currency' => 'USD'
    },
    'extra' => {
      'ip' => '192.168.0.1'
    }
  }
  transaction_payload2 = {
    'to' => {
      'type' => 'ACH-US',
      'id' => to_node['_id']
    },
    'amount' => {
      'amount' => 44,
      'currency' => 'USD'
    },
    'extra' => {
      'ip' => '192.168.0.1'
    }
  }
  client.trans.create(node_id: from_node['_id'], payload: transaction_payload1)
  client.trans.create(node_id: from_node['_id'], payload: transaction_payload2)
  client
end

def oauth_user(client, user_id)
  user = client.users.get(user_id: user_id)
  client.users.refresh(payload: {'refresh_token' => user['refresh_token']})
  user
end

def test_user
  SynapsePayRest::User.create(
    client: test_client,
    logins: [{email: 'betty@white.com'}],
    phone_numbers: ['415-555-5555'],
    legal_names: ['Betty White']
  )
end

def test_user_with_one_cip_document

  cip_info = {
    email: 'piper@pie.com',
    phone_number: '4444444',
    ip: '127002',
    name: 'Piper',
    alias: 'Hallowell',
    entity_type: 'F',
    entity_scope: 'Arts & Entertainment',
    birth_day: 1,
    birth_month: 2,
    birth_year: 1933,
    address_street: '333 14th St',
    address_city: 'SF',
    address_subdivision: 'CA',
    address_postal_code: '94114',
    address_country_code: 'US',
    social_documents: [test_social_document]
  }
  test_user.create_cip_document(cip_info)
end

def test_user_with_cip_document_with_three_documents
  cip_info = {
    email: 'piper@pie.com',
    phone_number: '4444444',
    ip: '127002',
    name: 'Piper',
    alias: 'Hallowell',
    entity_type: 'F',
    entity_scope: 'Arts & Entertainment',
    birth_day: 1,
    birth_month: 2,
    birth_year: 1933,
    address_street: '333 14th St',
    address_city: 'SF',
    address_subdivision: 'CA',
    address_postal_code: '94114',
    address_country_code: 'US',
    physical_documents: [test_physical_document],
    social_documents: [test_social_document],
    virtual_documents: [test_virtual_document]
  }
  test_user.create_cip_document(cip_info)
end

def test_physical_document
  SynapsePayRest::PhysicalDocument.create(
    type: 'GOVT_ID',
    value: 'data:text/csv;base64,SUQs=='
  )
end

def test_social_document
  SynapsePayRest::SocialDocument.create(
    type: 'PHONE_NUMBER',
    value: '415-555-5555'
  )
end

def test_virtual_document
  SynapsePayRest::VirtualDocument.create(
    type: 'SSN',
    value: '2222'
  )
end

def test_cip_document_with_documents
  cip_info = {
    user: test_user,
    email: 'piper@pie.com',
    phone_number: '4444444',
    ip: '127002',
    name: 'Piper',
    alias: 'Hallowell',
    entity_type: 'F',
    entity_scope: 'Arts & Entertainment',
    birth_day: 1,
    birth_month: 2,
    birth_year: 1933,
    address_street: '333 14th St',
    address_city: 'SF',
    address_subdivision: 'CA',
    address_postal_code: '94114',
    address_country_code: 'US',
    physical_documents: [test_physical_document],
    social_documents: [test_social_document],
    virtual_documents: [test_virtual_document]
  }
  SynapsePayRest::CipDocument.create(cip_info)
end
