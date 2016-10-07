module SynapsePayRest
  # Wrapper class for /trans endpoints
  class Transactions
    # @todo Implement idempotency keys

    # Valid optional args for #get
    # @todo Refactor to HTTPClient
    VALID_QUERY_PARAMS = [:page, :per_page].freeze

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end

    # Sends a GET request to /trans endpoint. Queries a specific transaction_id
    # if trans_id supplied, else queries all transactions. Returns the response.
    # 
    # @param node_id [String] id of the from node
    # @param trans_id [String,nil] (optional) id of a transaction to look up
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def get(node_id:, trans_id: nil, **options)
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)

      # @todo Should factor this out into HTTPClient
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      # @todo Probably should use CGI or RestClient's param builder instead of
      # rolling our own, probably error-prone and untested version
      # https://github.com/rest-client/rest-client#usage-raw-url
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a POST request to /trans endpoint to create a new transaction.
    # Returns the response.
    # 
    # @param node_id [String] id of the from node
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/create-transaction payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def create(node_id:, payload:)
      path = create_transaction_path(node_id: node_id)
      client.post(path, payload)
    end

    # Sends a PATCH request to /trans endpoint to update a transaction. 
    # Returns the response.
    # 
    # @param node_id [String] id of the from node
    # @param trans_id [String] id of a transaction to update
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/update-transaction payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def update(node_id:, trans_id:, payload:)
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.patch(path, payload)
    end

    # Sends a DELETE request to /trans endpoint to cancel a transaction.
    # Returns the response.
    # 
    # @param node_id [String] id of the from node
    # @param trans_id [String] id of a transaction to delete
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def delete(node_id:, trans_id:)
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.delete(path)
    end

    private

    def create_transaction_path(node_id:, trans_id: nil)
      path = ['/users', client.user_id, 'nodes', node_id, 'trans' ]
      path << trans_id if trans_id
      return path.join('/')
    end
  end
end
