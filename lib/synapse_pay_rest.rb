require 'synapse_pay_rest/client'
require 'synapse_pay_rest/http_client'
require 'synapse_pay_rest/error'
require 'synapse_pay_rest/version'
# base API clients
require 'synapse_pay_rest/api/users'
require 'synapse_pay_rest/api/nodes'
require 'synapse_pay_rest/api/transactions'
# model abstractions
require 'synapse_pay_rest/models/question'
require 'synapse_pay_rest/models/document'
require 'synapse_pay_rest/models/social_document'
require 'synapse_pay_rest/models/virtual_document'
require 'synapse_pay_rest/models/physical_document'
require 'synapse_pay_rest/models/cip_document'
require 'synapse_pay_rest/models/user'
require 'synapse_pay_rest/models/node'
require 'synapse_pay_rest/models/transaction'
require 'pry'

module SynapsePayRest
  # deprecated classes
  def self.const_missing(const_name)
    super unless const_name == :Trans
    warn caller.first + " DEPRECATION WARNING: the class SynapsePayRest::#{const_name} is deprecated. Use SynapsePayRest::Transactions instead."
    Transactions
  end
end
