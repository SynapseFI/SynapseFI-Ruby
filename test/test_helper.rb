require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'synapse_pay_rest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'faker'
require 'dotenv'
# load environment variables
Dotenv.load

Minitest::Reporters.use!([Minitest::Reporters::SpecReporter.new])

TEST_ROOT = File.dirname(File.expand_path('.', __FILE__))
# require test factories
Dir["#{TEST_ROOT}/factories/*.rb"].each {|file| require file }

# @todo organize tests better (e.g. by node type instead of all nodes together)

def fixture_path(file_name)
  "#{TEST_ROOT}/fixtures/#{file_name}"
end

def refresh_user(client, user_id)
  user = client.users.get(user_id: user_id)
  client.users.refresh(user_id: user_id, payload: {'refresh_token' => user['refresh_token']})
  user
end

def kyc_user(user)
  args = test_base_document_args
  args.delete(:user)
  base_doc = user.create_base_document(args)
  user = base_doc.user
end
