module SynapsePayRest
  # Wrapper class for /client endpoint
  class Statements

    # Valid optional args for #get
    # @todo Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:page, :per_page].freeze

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end
    
    # Sends a GET request /node or /user statments endpoint to retrieve statements, and returns the
    # response.
    # 
    # @param user_id [String]
    # @param node_id [String] optional
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def get(user_id:, node_id: nil, **options)
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path = "/users/#{user_id}"
      path += "/nodes/#{node_id}" if node_id
      path += "/statements"
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end
    
  end
end
