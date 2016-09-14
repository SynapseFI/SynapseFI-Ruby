require "synapse_pay_rest/http_client"
require "synapse_pay_rest/error"
require "synapse_pay_rest/api/users"
require "synapse_pay_rest/api/nodes"
require "synapse_pay_rest/api/trans"

module SynapsePayRest

  class Client
    attr_accessor :client, :users, :nodes, :trans

    def initialize(options: raise("options is required"), user_id: nil)
      base_url = if options['development_mode']
                   'https://sandbox.synapsepay.com/api/3'
                 else
                   'https://synapsepay.com/api/3'
                 end

      @client = HTTPClient.new options, base_url, user_id: user_id
      @users = Users.new @client
      @nodes = Nodes.new @client
      @trans = Trans.new @client
    end
  end
end
