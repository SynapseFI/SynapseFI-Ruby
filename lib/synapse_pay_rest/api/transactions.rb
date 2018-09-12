module SynapsePayRest
  # Wrapper class for /trans endpoints
  # 
  # @todo Implement idempotency keys
  class Transactions

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
    # @param user_id [String]
    # @param node_id [String] id of the from node
    # @param trans_id [String,void] (optional) id of a transaction to look up
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    # 
    # @todo Probably should use CGI or RestClient's param builder instead of
    # rolling our own, probably error-prone and untested version
    # https://github.com/rest-client/rest-client#usage-raw-url
    def get(user_id:, node_id:, trans_id: nil, **options)
      path = create_transaction_path(user_id: user_id, node_id: node_id, trans_id: trans_id)

      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a POST request to /trans endpoint to create a new transaction.
    # Returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String] id of the from node
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/create-transaction payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def create(user_id:, node_id:, payload:, idempotency_key: nil)
      path = create_transaction_path(user_id: user_id, node_id: node_id)
      client.post(path, payload, idempotency_key: idempotency_key)
    end

    # Sends a PATCH request to /trans endpoint to update a transaction. 
    # Returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String] id of the from node
    # @param trans_id [String] id of a transaction to update
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/update-transaction payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def update(user_id:, node_id:, trans_id:, payload:)
      path = create_transaction_path(user_id: user_id, node_id: node_id, trans_id: trans_id)
      client.patch(path, payload)
    end

    # Sends a DELETE request to /trans endpoint to cancel a transaction.
    # Returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String] id of the from node
    # @param trans_id [String] id of a transaction to delete
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def delete(user_id:, node_id:, trans_id:)
      path = create_transaction_path(user_id: user_id, node_id: node_id, trans_id: trans_id)
      client.delete(path)
    end

    private

    def create_transaction_path(user_id:, node_id:, trans_id: nil)
      path = "/users/#{user_id}/nodes/#{node_id}/trans"
      path += "/#{trans_id}" if trans_id
      path
    end
  end
end
