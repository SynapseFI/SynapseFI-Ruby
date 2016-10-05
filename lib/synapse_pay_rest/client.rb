module SynapsePayRest
  class Client
    attr_accessor :http_client, :users, :nodes, :transactions

    def initialize(client_id:, client_secret:, ip_address:, fingerprint: nil, user_id: nil,
                   development_mode: false, **options)
      # keeping the options['development_mode'] alterative for backwards compatibility
      base_url = if development_mode || options['development_mode']
                   'https://sandbox.synapsepay.com/api/3'
                 else
                   'https://synapsepay.com/api/3'
                 end

      @http_client  = HTTPClient.new(base_url: base_url,
                                     client_id: client_id,
                                     client_secret: client_secret,
                                     user_id: user_id,
                                     fingerprint: fingerprint,
                                     ip_address: ip_address,
                                     **options)
      @users        = Users.new @http_client
      @nodes        = Nodes.new @http_client
      @transactions = Transactions.new @http_client
    end

    # support old reader/var names
    alias_method :trans, :transactions
    alias_method :client, :http_client
  end
end
