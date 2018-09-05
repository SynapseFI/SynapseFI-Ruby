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
    # @!attribute [rw] subscriptions
    #   @return [SynapsePayRest::Subscriptions]
    attr_accessor :http_client, :users, :nodes, :subnets, :transactions, :subscriptions, :institutions,
                  :client_endpoint, :atms, :crypto_quotes, :statements

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
                   'https://uat-api.synapsefi.com/v3.1'
                 else
                   'https://api.synapsefi.com/v3.1'
                 end

      @http_client  = HTTPClient.new(base_url: base_url,
                                     client_id: client_id,
                                     client_secret: client_secret,
                                     fingerprint: fingerprint,
                                     ip_address: ip_address,
                                     **options)
      @users            = Users.new @http_client
      @nodes            = Nodes.new @http_client
      @subnets          = Subnets.new @http_client
      @transactions     = Transactions.new @http_client
      @subscriptions    = Subscriptions.new @http_client
      @institutions     = Institutions.new @http_client
      @client_endpoint  = ClientEndpoint.new @http_client
      @atms             = Atms.new @http_client
      @crypto_quotes    = CryptoQuotes.new @http_client
      @statements       = Statements.new @http_client
    end

  

    def issue_public_key(scope: "OAUTH|POST,USERS|POST,USERS|GET,USER|GET,USER|PATCH,SUBSCRIPTIONS|GET,SUBSCRIPTIONS|POST,SUBSCRIPTION|GET,SUBSCRIPTION|PATCH,CLIENT|REPORTS,CLIENT|CONTROLS")
      PublicKey.issue(client: self, scope: scope)
    end

    def get_crypto_quotes()
      CryptoQuote.get(client: self)
    end

  end
end
