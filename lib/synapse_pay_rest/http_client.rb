require 'rest-client'

module SynapsePayRest
  class HTTPClient

    attr_accessor :base_url, :options, :headers, :user_id

    # By the way, this is a really badly designed initializer
    # If the "options" are truely optional, then Ruby lets the last
    # argument be a hash. But in this case, these are not options so
    # much as required configurations. Should just be called config
    # And why is that in front of the base_url?
    def initialize(options, base_url, user_id: nil)
      @options = options
      @base_url = base_url
      # RestClient.log = 'stdout'
      @user_id = user_id
    end

    def get_headers()
      user    = "#{options['oauth_key']}|#{options['fingerprint']}"
      gateway = "#{options['client_id']}|#{options['client_secret']}"
      headers = {
        :content_type => :json,
        :accept => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER' => user,
        'X-SP-USER-IP' => options['ip_address'] 
      }
    end

    def update_headers(user_id: nil, oauth_key: nil, fingerprint: nil, client_id: nil, client_secret: nil, ip_address: nil)
      self.user_id  = user_id if user_id
      options['fingerprint']   = fingerprint if fingerprint
      options['oauth_key']     = oauth_key if oauth_key
      options['client_id']     = client_id if client_id
      options['client_secret'] = client_secret if client_secret
      options['ip_address']    = ip_address if ip_address
    end


    def post(path, payload)
      response = with_error_handling { RestClient.post(full_url(path), payload.to_json, get_headers()) }
      JSON.parse(response)
    end

    def patch(path, payload)
      response = with_error_handling { RestClient.patch(full_url(path), payload.to_json, get_headers()) }
      JSON.parse(response)
    end

    def get(path)
      response = with_error_handling { RestClient.get(full_url(path), get_headers()) }
      JSON.parse(response)
    end

    def delete(path)
      response = with_error_handling { RestClient.delete(full_url(path), get_headers()) }
      JSON.parse(response)
    end

    private

    def full_url(path)
      "#{base_url}#{path}"
    end

    def with_error_handling
      yield
    rescue Exception => e
      # By the way, this is a really bad idea.
      # See: https://www.relishapp.com/womply/ruby-style-guide/docs/exceptions
      # The exceptions should be enumerated. Not all exceptions are going
      # to be parsable by JSON. The only one that should be captured are the
      # are the HTTP Client responses.
      return e.response
    end
  end
end
