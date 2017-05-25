module SynapsePayRest
  # Wrapper class for /subscriptions endpoints
  # 
  # @todo Implement idempotency keys
  class Subscriptions

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

    # Sends a POST request to /subscriptions endpoint to create a new subscription.
    # Returns the response.
    # 
    # @param url [String]
    # @param scope [Array]
    # @see https://docs.synapsepay.com/docs/create-subscription payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def create(payload:)
      path = subscription_path
      client.post(path, payload)
    end

    # Sends a GET request to /subscriptions endpoint. Queries a specific subscription_id
    # if subs_id supplied, else queries all subscriptions. Returns the response.
    # 
    # @param subscription_id [String,void] (optional) id of a subscription to look up
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
    def get(subscription_id: nil, **options)
      path = subscription_path(subscription_id: subscription_id)

      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a PATCH request to /subscriptions endpoint, updating the current subscription
    # and returns the response.
    # 
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/update-subscription payload structure for
    #   updating subscription
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def update(subscription_id:, payload:)
      path = subscription_path(subscription_id: subscription_id)
      client.patch(path, payload)
    end
    
    private

    def subscription_path(subscription_id: nil)
      path = "/subscriptions"
      path += "/#{subscription_id}" if subscription_id
      path
    end

  end
end
