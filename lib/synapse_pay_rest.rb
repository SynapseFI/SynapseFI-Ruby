require 'pry'

# clients
require 'synapse_pay_rest/client'
require 'synapse_pay_rest/http_client'

# base API
require 'synapse_pay_rest/api/users'
require 'synapse_pay_rest/api/nodes'
require 'synapse_pay_rest/api/transactions'

# library
require 'synapse_pay_rest/error'
require 'synapse_pay_rest/version'

# user-related models
require 'synapse_pay_rest/models/user/user'
require 'synapse_pay_rest/models/user/base_document'
require 'synapse_pay_rest/models/user/document'
require 'synapse_pay_rest/models/user/physical_document'
require 'synapse_pay_rest/models/user/social_document'
require 'synapse_pay_rest/models/user/virtual_document'
require 'synapse_pay_rest/models/user/question'

# node-related models
require 'synapse_pay_rest/models/node/node'

# transaction-related models
require 'synapse_pay_rest/models/transaction/transaction'

module SynapsePayRest
  # deprecated classes
  def self.const_missing(const_name)
    super unless const_name == :Trans
    warn caller.first + " DEPRECATION WARNING: the class SynapsePayRest::#{const_name} is deprecated. Use SynapsePayRest::Transactions instead."
    Transactions
  end
end
