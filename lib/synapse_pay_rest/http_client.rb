require 'rest-client'
require 'json'

module SynapsePayRest
  # Wrapper for HTTP requests using RestClient.
  class HTTPClient
    # @!attribute [rw] base_url
    #   @return [String] the base url of the API (production or sandbox)
    # @!attribute [rw] config
    #   @return [Hash] various settings related to request headers
    # @!attribute [rw] user_id
    #   @return [String] the user_id which is stored upon a call to Users#get or Users#create
    attr_accessor :base_url, :config, :user_id

    # @param base_url [String] the base url of the API (production or sandbox)
    # @param client_id [String]
    # @param client_secret [String]
    # @param fingerprint [String]
    # @param ip_address [String]
    # @param user_id [String] (optional) automatically stored on call to Users#get or Users#create
    # @param logging [Boolean] (optional) logs to stdout when true
    # @param log_to [String] (optional) file path to log to file (logging must be true)
    def initialize(base_url:, client_id:, fingerprint:, ip_address:, client_secret:,
                   user_id: nil, **options)

      log_to         = options[:log_to] || 'stdout'
      RestClient.log = log_to if options[:logging]

      @config = {
        fingerprint:   fingerprint,
        client_id:     client_id,
        client_secret: client_secret
      }
      @base_url = base_url
      @user_id  = user_id
    end

    # Returns headers for HTTP requests.
    # 
    # @return [Hash]
    def headers
      user    = "#{config[:oauth_key]}|#{config[:fingerprint]}"
      gateway = "#{config[:client_id]}|#{config[:client_secret]}"
      headers = {
        :content_type  => :json,
        :accept        => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER'    => user,
        'X-SP-USER-IP' => config[:ip_address]
      }
    end
    # Alias for #headers (legacy name)
    alias_method :get_headers, :headers

    # Updates headers and/or user_id.
    # 
    # @param user_id [String,void]
    # @param oauth_key [String,void]
    # @param fingerprint [String,void]
    # @param client_id [String,void]
    # @param client_secret [String,void]
    # @param ip_address [String,void]
    # 
    # @return [void]
    # 
    # @todo logic to update user_id doesn't belong here
    def update_headers(user_id: nil, oauth_key: nil, fingerprint: nil,
                       client_id: nil, client_secret: nil, ip_address: nil)
      self.user_id           = user_id if user_id
      config[:fingerprint]   = fingerprint if fingerprint
      config[:oauth_key]     = oauth_key if oauth_key
      config[:client_id]     = client_id if client_id
      config[:client_secret] = client_secret if client_secret
      config[:ip_address]    = ip_address if ip_address
      nil
    end

    # Sends a POST request to the given path with the given payload.
    # 
    # @param path [String]
    # @param payload [Hash]
    # 
    # @raise [SynapsePayRest::Error] subclass depends on HTTP response
    # 
    # @return [Hash] API response
    def post(path, payload)
      response = with_error_handling { RestClient.post(full_url(path), payload.to_json, headers) }
      JSON.parse(response)
    end

    # Sends a PATCH request to the given path with the given payload.
    # 
    # @param path [String]
    # @param payload [Hash]
    # 
    # @raise [SynapsePayRest::Error] subclass depends on HTTP response
    # 
    # @return [Hash] API response
    def patch(path, payload)
      response = with_error_handling { RestClient.patch(full_url(path), payload.to_json, headers) }
      JSON.parse(response)
    end

    # Sends a GET request to the given path with the given payload.
    # 
    # @param path [String]
    # 
    # @raise [SynapsePayRest::Error] subclass depends on HTTP response
    # 
    # @return [Hash] API response
    def get(path)
      response = with_error_handling { RestClient.get(full_url(path), headers) }
      JSON.parse(response)
    end

    # Sends a DELETE request to the given path with the given payload.
    # 
    # @param path [String]
    # 
    # @raise [SynapsePayRest::Error] subclass depends on HTTP response
    # 
    # @return [Hash] API response
    def delete(path)
      response = with_error_handling { RestClient.delete(full_url(path), headers) }
      JSON.parse(response)
    end

    private

    def full_url(path)
      "#{base_url}#{path}"
    end

    def with_error_handling
      yield
    rescue RestClient::Exception => e
      body = JSON.parse(e.response.body)
      raise Error.error_from_response(body, body['error_code'])
    end
  end
end
