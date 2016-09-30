$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapse_pay_rest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'faker'
require 'dotenv'

Dotenv.load

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

TEST_ROOT = File.dirname(File.expand_path('.', __FILE__))

# require test factories
Dir["#{TEST_ROOT}/factories/*.rb"].each {|file| require file }

def fixture_path(file_name)
  "#{TEST_ROOT}/fixtures/#{file_name}"
end

# create different number of users for different tests
def test_client_with_two_transactions
  client    = test_client_with_two_nodes
  nodes     = client.nodes.get['nodes']
  from_node = nodes.first
  to_node   = nodes.last

  transaction_payload1 = {
    'to' => {
      'type' => to_node['type'],
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
      'type' => to_node['type'],
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

def refresh_user(client, user_id)
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

def test_physical_document
  SynapsePayRest::PhysicalDocument.create(
    type: 'GOVT_ID',
    value: fixture_path('id.png')
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

def test_base_document_base_info
  {
    user: test_user,
    email: "piper+#{rand(100000000)}@pie.com",
    phone_number: '4444444',
    ip: '127002',
    name: 'Piper Hallowell',
    alias: 'Pipesicle',
    entity_type: 'F',
    entity_scope: 'Arts & Entertainment',
    birth_day: 1,
    birth_month: 2,
    birth_year: 1933,
    address_street: '333 14th St',
    address_city: 'SF',
    address_subdivision: 'CA',
    address_postal_code: '94114',
    address_country_code: 'US'
  }
end

def test_base_document_base_info_with_three_documents
  test_base_document_base_info.merge({
    physical_documents: [test_physical_document],
    social_documents: [test_social_document],
    virtual_documents: [test_virtual_document]
  })
end

def test_user_with_one_base_document
  args = test_base_document_base_info
  args.delete(:user)
  test_user.create_base_document(args)
end

def test_base_document_with_three_documents
  SynapsePayRest::BaseDocument.create(test_base_document_base_info_with_three_documents)
end

def test_user_with_base_document_with_three_documents
  args = test_base_document_base_info_with_three_documents
  # create_base_document does not accept a user argument
  args.delete(:user)
  user = test_user
  user.create_base_document(args)
  user
end

def test_user_with_two_nodes
  user = test_user
  args = {
    user: user,
    bank_name: 'bofa',
    username: 'synapse_nomfa',
    password: 'test1234'
  }
  nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)
  user
end
