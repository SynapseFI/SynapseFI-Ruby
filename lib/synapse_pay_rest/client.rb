module SynapsePayRest
  class Client
    attr_accessor :client, :users, :nodes, :transactions

    # need to allow symbols in options, validate arg class, default to sandbox
    def initialize(options: raise("options is required"), user_id: nil)
      base_url = if options['development_mode']
                   'https://sandbox.synapsepay.com/api/3'
                 else
                   'https://synapsepay.com/api/3'
                 end

      # rename to @http_client
      @client = HTTPClient.new options, base_url, user_id: user_id
      @users = Users.new @client
      @nodes = Nodes.new @client
      @transactions = Transactions.new @client
    end
    alias_method :trans, :transactions
  end
end
