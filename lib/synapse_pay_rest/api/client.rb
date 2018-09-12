module SynapsePayRest
  # Wrapper class for /client endpoint
  class ClientEndpoint

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end
    
    # Sends a GET request to /client endpoint to issue public key, and returns the
    # response.
    # 
    # @param scope [String]
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def issue_public_key(scope: "OAUTH|POST,USERS|POST,USERS|GET,USER|GET,USER|PATCH,SUBSCRIPTIONS|GET,SUBSCRIPTIONS|POST,SUBSCRIPTION|GET,SUBSCRIPTION|PATCH,CLIENT|REPORTS,CLIENT|CONTROLS")
      path = '/client?issue_public_key=YES'
      path += "&scope=#{scope}"
      client.get(path)
    end
    
  end
end