module SynapsePayRest
  # Wrapper class for /institutions endpoints
  class Institutions

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end

    # Sends a GET request to /v3.1/institutions endpoint. 
    # 
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    # 
    # @todo Probably should use CGI or RestClient's param builder instead of
    # rolling our own, probably error-prone and untested version
    # https://github.com/rest-client/rest-client#usage-raw-url
    def get()
      path = '/institutions'
      client.get(path)
    end
    
  end
end
