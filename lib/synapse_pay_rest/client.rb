module SynapsePayRest
  # Initializes various wrapper settings such as development mode and request
  # header values. Also stores and initializes endpoint class instances 
  # (Users, Nodes, Transactions) for making API calls.
  class Client
    # @!attribute [rw] http_client
    #   @return [SynapsePayRest::HTTPClient]
    # @!attribute [rw] users
    #   @return [SynapsePayRest::Users]
    # @!attribute [rw] nodes
    #   @return [SynapsePayRest::Nodes]
    # @!attribute [rw] transactions
    #   @return [SynapsePayRest::Transactions]
    attr_accessor :http_client, :users, :nodes, :transactions

    # Alias for #transactions (legacy name)
    alias_method :trans, :transactions
    # Alias for #http_client (legacy name)
    alias_method :client, :http_client

    # @param client_id [String] should be stored in environment variable
    # @param client_secret [String] should be stored in environment variable
    # @param ip_address [String] user's IP address
    # @param fingerprint [String] a hashed value, either unique to user or static
    # @param user_id [String] (optional)
    # @param development_mode [String] default true
    # @param logging [Boolean] (optional) logs to stdout when true
    # @param log_to [String] (optional) file path to log to file (logging must be true)
    def initialize(client_id:, client_secret:, ip_address:, fingerprint: nil,
                   user_id: nil, development_mode: true, **options)
      base_url = 'https://api-qa.synapsefi.com/v3.1'

      @http_client  = HTTPClient.new(base_url: base_url,
                                     client_id: 'client_id_b8d24e32b6aa11e6bba40242ac110003',
                                     client_secret: 'test1234',
                                     user_id: user_id,
                                     fingerprint: 'e716990e50b67a1177736960b6357524b22090ccab093d068b3d7a18dbde3f4c',
                                     ip_address: ip_address,
                                     **options)
      @users        = Users.new @http_client
      @nodes        = Nodes.new @http_client
      @transactions = Transactions.new @http_client
    end
  end
end
