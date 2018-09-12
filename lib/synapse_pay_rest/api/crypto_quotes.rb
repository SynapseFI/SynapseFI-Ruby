module SynapsePayRest
  # Wrapper class for /client endpoint
  class CryptoQuotes

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end
    
    # Sends a GET request to /crypto-quotes endpoint to get btc exchange rate and returns the
    # response.
    # 
    # @param scope [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def get()
      path = '/nodes/crypto-quotes'
      client.get(path)
    end
    private
    
  end
end