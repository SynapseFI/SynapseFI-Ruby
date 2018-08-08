module SynapsePayRest
  # Wrapper class for /client endpoint
  class Atms
    VALID_QUERY_PARAMS = [:page, :per_page, :radius, :zip, :lat, :lon].freeze

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end
    
    # Sends a GET request to /nodes endpoint to locate atms, and returns the
    # response.
    # 
    # @param scope [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API responsea
    def locate(**options)
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path = "/nodes/atms?"
      path += params.join('&') if params.any?
      client.get(path)
    end
    
  end
end