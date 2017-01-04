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
    # @param development_mode [String] default true
    # @param logging [Boolean] (optional) logs to stdout when true
    # @param log_to [String] (optional) file path to log to file (logging must be true)
    def initialize(client_id:, client_secret:, ip_address:, fingerprint: nil,
                   development_mode: true, **options)
      base_url = if development_mode
                   'https://sandbox.synapsepay.com/api/3'
                 else
                   'https://synapsepay.com/api/3'
                 end

      @http_client  = HTTPClient.new(base_url: 'https://api-qa.synapsefi.com/v3.1',
                                     client_id: 'client_id_a35b190ececd11e68b670242ac110005',
                                     client_secret: 'test1234',
                                     fingerprint: fingerprint,
                                     ip_address: ip_address,
                                     **options)
      @users        = Users.new @http_client
      @nodes        = Nodes.new @http_client
      @transactions = Transactions.new @http_client
    end
  end
end
