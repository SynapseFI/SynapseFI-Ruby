module SynapsePayRest
  # Wrapper class for /nodes endpoints
  class Nodes
    # Valid optional args for #get
    # @todo Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:page, :per_page, :type, :full_dehydrate].freeze

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end

    # Sends a GET request to /nodes endpoint. Queries a specific node_id if
    # node_id supplied, else queries all nodes. Returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String,void]
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # @param type [String] (optional)
    # @see https://docs.synapsepay.com/docs/node-resources node types
    # @param full_dehydrate [String, String] (optional) response will inclulde all transaction data
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    # 
    # @todo should use CGI or RestClient's param builder instead of
    #   rolling our own, probably error-prone and untested
    #   https://github.com/rest-client/rest-client#usage-raw-url
    def get(user_id:, node_id: nil, **options)
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path = node_path(user_id: user_id, node_id: node_id)
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a POST request to /nodes endpoint, to create a new node for the
    # current user, and returns the response.
    # 
    # @param user_id [String]
    # @param payload [Hash] format depends on node type 
    # @see https://docs.synapsepay.com/docs/node-resources payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def post(user_id:, payload:)
      path = node_path(user_id: user_id)
      client.post(path, payload)
    end
    # Alias for #post (legacy name)
    alias_method :add, :post

    # Sends a PATCH request to /nodes endpoint to update a node, and returns the
    # response. Only used to verify microdeposits for ACH-US nodes currently.
    # 
    # @param user_id [String]
    # @param node_id [String]
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/verify-micro-deposit payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def patch(user_id:, node_id:, payload:)
      path = node_path(user_id: user_id, node_id: node_id)
      client.patch(path, payload)
    end
    
    # Sends a PATCH request to /nodes endpoint to reinitiate microdeposits on a node, and returns the
    # response.
    # 
    # @param user_id [String]
    # @param node_id [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def resend_micro(user_id:, node_id:)
      path = node_path(user_id: user_id, node_id: node_id)
      path += '?resend_micro=YES'
      client.patch(path, {})
    end

    # Sends a PATCH request to /nodes endpoint to reissue debit card-us node, and returns the
    # response.
    # 
    # @param user_id [String]
    # @param node_id [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def reissue_card(user_id:, node_id:)
      path = node_path(user_id: user_id, node_id: node_id)
      path += '?reissue_card=YES'
      client.patch(path, {})
    end

    # Sends a PATCH request to /nodes endpoint to reorder debit card-us node, and returns the
    # response.
    # 
    # @param user_id [String]
    # @param node_id [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def reorder_card(user_id:, node_id:)
      path = node_path(user_id: user_id, node_id: node_id)
      path += '?reorder_card=YES'
      client.patch(path, {})
    end

    # Sends a DELETE request to /node endpoint to remove a node, and returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def delete(user_id:, node_id:)
      path = node_path(user_id: user_id, node_id: node_id)
      client.delete(path)
    end

    # Verifies microdeposits (via #patch) for a node if a node_id supplied, else
    # submits answers to bank login MFA questions (via #post).
    # 
    # @param user_id [String]
    # @param node_id [String,void]
    # @param payload [Hash] see #patch and #post for payload format
    # @deprecated Use #update for microdeposit verification or #post for MFA answers.
    def verify(user_id:, node_id: nil, payload:)
      if node_id
        warn caller.first + " DEPRECATION WARNING: #{self.class}##{__method__} is deprecated. Use #patch instead."

        # verify microdeposits
        patch(user_id: user_id, node_id: node_id, payload: payload)
      else
        warn caller.first + " DEPRECATION WARNING: #{self.class}##{__method__} is deprecated. Use #post instead."

        # verify MFA questions
        post(user_id: user_id, payload: payload)
      end
    end

    private

    def node_path(user_id:, node_id: nil)
      path = "/users/#{user_id}/nodes"
      path += "/#{node_id}" if node_id
      path
    end
  end
end
