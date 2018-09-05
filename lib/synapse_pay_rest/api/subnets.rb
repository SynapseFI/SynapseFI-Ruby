module SynapsePayRest
  # Wrapper class for /subnets endpoints
  # 
  class Subnets

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

    # Sends a GET request to /subnets endpoint. Queries a specific subnet_id
    # if subnet_id supplied, else queries all transactions. Returns the response.
    # 
    # @param user_id [String]
    # @param node_id [String] id of node
    # @param subnet_id [String,void] (optional) id of a subnet to look up
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    # 
    def get(user_id:, node_id:, subnet_id: nil, **options)
      path = create_subnet_path(user_id: user_id, node_id: node_id, subnet_id: subnet_id)

      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a POST request to /subents endpoint to create a new subnet.
    # Returns the response.
    # 
    # @param user_id [String] user_id associated with the subnet
    # @param node_id [String] node the subnet belongs to
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/create-subnet payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def create(user_id:, node_id:, payload:)
      path = create_subnet_path(user_id: user_id, node_id: node_id)
      client.post(path, payload)
    end

    # Sends a PATCH request to /subnets endpoint to update a subnet. 
    # Returns the response.
    # 
    # @param user_id [String] id of user associated with the subnet
    # @param node_id [String] id of node the subnet belongs to
    # @param subnet_id [String] id of subnet
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/subnet-1 payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def update(user_id:, node_id:, subnet_id:, payload:)
      path = create_subnet_path(user_id: user_id, node_id: node_id, subnet_id: subnet_id)
      client.patch(path, payload)
    end

    private

    def create_subnet_path(user_id:, node_id:, subnet_id: nil)
      path = "/users/#{user_id}/nodes/#{node_id}/subnets"
      path += "/#{subnet_id}" if subnet_id
      path
    end
  end
end
