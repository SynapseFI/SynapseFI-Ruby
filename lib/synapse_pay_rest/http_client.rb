require 'rest-client'
require 'json'

module SynapsePayRest
  # Wrapper for HTTP requests using RestClient.
  class HTTPClient
    # @!attribute [rw] base_url
    #   @return [String] the base url of the API (production or sandbox)
    # @!attribute [rw] config
    #   @return [Hash] various settings related to request headers
    attr_accessor :base_url, :config

    # @param base_url [String] the base url of the API (production or sandbox)
    # @param client_id [String]
    # @param client_secret [String]
    # @param fingerprint [String]
    # @param ip_address [String]
    # @param logging [Boolean] (optional) logs to stdout when true
    # @param log_to [String] (optional) file path to log to file (logging must be true)
    # @param proxy_url [String] (optional) proxy url which is used to proxy outbound requests
    def initialize(base_url:, client_id:, fingerprint:, ip_address:,
                   client_secret:, **options)
      log_to         = options[:log_to] || 'stdout'
      RestClient.log = log_to if options[:logging]
      @logging       = options[:logging]

      @sandbox_url = options[:sandbox_url]
      @live_url = options[:live_url]

      puts "URLs:\n#{@sandbox_url}\n#{@live_url}" if @logging

      @config = {
        client_id:     client_id,
        client_secret: client_secret,
        fingerprint:   fingerprint,
        ip_address:    ip_address,
        oauth_key:     '',
      }
      @base_url = base_url
    end

    # Returns headers for HTTP requests.
    # 
    # @return [Hash]
    def headers
      user    = "#{config[:oauth_key]}|#{config[:fingerprint]}"
      gateway = "#{config[:client_id]}|#{config[:client_secret]}"

      access_control_headers = {
        'Access-Control-Allow-Methods' => 'GET,PUT,POST,DELETE,OPTIONS',
        'Access-Control-Allow-Headers' => 'X-Requested-With,Content-type,Accept,X-Access-Token,X-Key',
        'Access-Control-Allow-Origin' => '*'
      }

      request_headers = {
        :content_type  => :json,
        :accept        => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER'    => user,
        'X-SP-USER-IP' => config[:ip_address]
      }

      request_headers.merge!(access_control_headers) if @proxy_url
      request_headers
    end
    # Alias for #headers (legacy name)
    alias_method :get_headers, :headers

    # Updates headers.
    # 
    # @param oauth_key [String,void]
    # @param fingerprint [String,void]
    # @param client_id [String,void]
    # @param client_secret [String,void]
    # @param ip_address [String,void]
    # 
    # @return [void]
    def update_headers(oauth_key: nil, fingerprint: nil, client_id: nil,
                       client_secret: nil, ip_address: nil, **options)
      config[:fingerprint]   = fingerprint if fingerprint
      config[:oauth_key]     = oauth_key if oauth_key
      config[:client_id]     = client_id if client_id
      config[:client_secret] = client_secret if client_secret
      config[:ip_address]    = ip_address if ip_address
      nil
    end

    def ssl_certicate
      pem = @development_mode ? Vgs::SANDBOX_PEM : Vgs::LIVE_PEM
      OpenSSL::X509::Certificate.new(pem)
    end

    def proxy_url
      @development_mode ? @sandbox_url : @live_url
    end

    def with_vgs_tunnel
      puts "Proxy URL: #{proxy_url}"
      RestClient.proxy = proxy_url
      yield
      RestClient.proxy = nil
    end

    # Sends a POST request to the given path with the given payload.
    # 
    # @param path [String]
    # @param payload [Hash]
    # @param idempotency_key [String] (optional) avoid accidentally performing the same operation twice
    #
    # @raise [SynapsePayRest::Error] subclass depends on HTTP response
    # 
    # @return [Hash] API response
    def post(path, payload, **options)
      puts '-- POST --------' if @logging
      headers = get_headers
      puts "Headers: #{headers}" if @logging
      puts "Options: #{options}" if @logging

      if options[:idempotency_key]
        headers = headers.merge({'X-SP-IDEMPOTENCY-KEY' => options[:idempotency_key]})
      end

      response = RestClient::Request.execute(method: :post,
                                             url: full_url(path),
                                             payload: payload.to_json,
                                             ssl_client_cert: ssl_certicate,
                                             verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                             proxy: @sandbox_url,
                                             headers: headers)
      puts "Response: #{response}" if @logging
      puts '-- POST --------' if @logging
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
      response = with_error_handling { RestClient::Request.execute(:method => :patch, :url => full_url(path), :payload => payload.to_json, :headers => headers, :timeout => 300) }
      p 'RESPONSE:', JSON.parse(response) if @logging
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
      puts '-- Request: GET ------------'
      puts "URI: #{full_url(path)}"

      response = RestClient::Request.execute(method: :get,
                                             url: full_url(path),
                                             ssl_client_cert: ssl_certicate,
                                             verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                             proxy: @sandbox_url,
                                             headers: headers)

      p 'RESPONSE:', JSON.parse(response) #if @logging
      puts '-- Request: GET ------------'
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
      p 'RESPONSE:', JSON.parse(response) if @logging
      JSON.parse(response)
    end

    private

    def full_url(path)
      "#{base_url}#{path}"
    end

    def with_error_handling
      yield
    rescue RestClient::Exceptions::Timeout
      body = {
        error: {
          en: "Request Timeout"
        },
        http_code: 504
      }
      raise Error.from_response(body)
    rescue RestClient::Exception => e
      if e.response.headers[:content_type] == 'application/json' 
        body = JSON.parse(e.response.body)
      else
        body = {
          error: {
            en: e.response.body
          },
          http_code: e.response.code
        }
      end
      raise Error.from_response(body)
    end
  end
end
