# client classes
require './lib/synapse_pay_rest/client'
require './lib/synapse_pay_rest/http_client'

# base API classes
require './lib/synapse_pay_rest/api/users'
require './lib/synapse_pay_rest/api/nodes'
require './lib/synapse_pay_rest/api/subnets'
require './lib/synapse_pay_rest/api/transactions'
require './lib/synapse_pay_rest/api/subscriptions'
require './lib/synapse_pay_rest/api/institutions'
require './lib/synapse_pay_rest/api/client'

# general library classes
require './lib/synapse_pay_rest/error'
require './lib/synapse_pay_rest/version'

# user-related classes
require './lib/synapse_pay_rest/models/user/user'
require './lib/synapse_pay_rest/models/user/base_document'
require './lib/synapse_pay_rest/models/user/document'
require './lib/synapse_pay_rest/models/user/physical_document'
require './lib/synapse_pay_rest/models/user/social_document'
require './lib/synapse_pay_rest/models/user/virtual_document'
require './lib/synapse_pay_rest/models/user/question'

# node-related classes

# ancestor of all node classes
require './lib/synapse_pay_rest/models/node/base_node'

# BaseNode subclasses
# synapse
require './lib/synapse_pay_rest/models/node/synapse_us_node.rb'
require './lib/synapse_pay_rest/models/node/synapse_ind_node.rb'
require './lib/synapse_pay_rest/models/node/synapse_np_node.rb'
require './lib/synapse_pay_rest/models/node/subaccount_us_node.rb'

# ach
require './lib/synapse_pay_rest/models/node/ach_us_node.rb'
require './lib/synapse_pay_rest/models/node/unverified_node.rb'
#check
require './lib/synapse_pay_rest/models/node/check_us_node.rb'
# eft
require './lib/synapse_pay_rest/models/node/eft_ind_node.rb'
require './lib/synapse_pay_rest/models/node/eft_np_node.rb'
# wire
require './lib/synapse_pay_rest/models/node/wire_us_node.rb'
require './lib/synapse_pay_rest/models/node/wire_int_node.rb'
# reserve
require './lib/synapse_pay_rest/models/node/reserve_us_node.rb'
# triump subaccount
require './lib/synapse_pay_rest/models/node/triumph_subaccount_us_node.rb'
require './lib/synapse_pay_rest/models/node/subaccount_us_node.rb'
require './lib/synapse_pay_rest/models/node/deposit_us_node.rb'

require './lib/synapse_pay_rest/models/node/clearing_us_node.rb'
require './lib/synapse_pay_rest/models/node/ib_deposit_us_node.rb'
require './lib/synapse_pay_rest/models/node/ib_subaccount_us_node.rb'
require './lib/synapse_pay_rest/models/node/interchange_us_node.rb'

# iou
require './lib/synapse_pay_rest/models/node/iou_node.rb'

# BaseNode factory
require './lib/synapse_pay_rest/models/node/node'

# subnet-related classes
require './lib/synapse_pay_rest/models/subnet/subnet'

# transaction-related classes
require './lib/synapse_pay_rest/models/transaction/transaction'

# subscription-related classes
require './lib/synapse_pay_rest/models/subscription/subscription'

# institution-related classes
require './lib/synapse_pay_rest/models/institution/institution'

require './lib/synapse_pay_rest/models/client/issue_public_key'



# Namespace for all SynapsePayRest classes and modules
module SynapsePayRest
  # Modifies the default method to print a warning when deprecated constants
  # used and returns the new constant.
  #
  # @param [Constant]
  # @return [Constant] the corresponding constant that is not deprecated.
  def self.const_missing(const_name)
    super unless const_name == :Trans
    warn caller.first + " DEPRECATION WARNING: the class SynapsePayRest::#{const_name}"\
                        'is deprecated. Use SynapsePayRest::Transactions instead.'
    Transactions
  end
end
