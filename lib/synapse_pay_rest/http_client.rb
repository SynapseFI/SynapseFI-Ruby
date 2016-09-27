require 'rest-client'
require 'json'

module SynapsePayRest
  class HTTPClient
    attr_accessor :base_url, :config, :headers, :user_id

    def initialize(config, base_url, user_id: nil)
      @config = config
      @base_url = base_url
      # RestClient.log = 'stdout'
      @user_id = user_id
    end

    def get_headers
      # refactor to use symbols
      user    = "#{config['oauth_key']}|#{config['fingerprint']}"
      gateway = "#{config['client_id']}|#{config['client_secret']}"
      headers = {
        :content_type => :json,
        :accept => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER' => user,
        'X-SP-USER-IP' => config['ip_address'] 
      }
    end

    def update_headers(user_id: nil, oauth_key: nil, fingerprint: nil, client_id: nil, client_secret: nil, ip_address: nil)
      # this doesn't really belongs in headers
      self.user_id = user_id if user_id

      config['fingerprint']   = fingerprint if fingerprint
      config['oauth_key']     = oauth_key if oauth_key
      config['client_id']     = client_id if client_id
      config['client_secret'] = client_secret if client_secret
      config['ip_address']    = ip_address if ip_address
    end

    def post(path, payload)
      response = with_error_handling { RestClient.post(full_url(path), payload.to_json, get_headers) }
      JSON.parse(response)
    end

    def patch(path, payload)
      response = with_error_handling { RestClient.patch(full_url(path), payload.to_json, get_headers) }
      JSON.parse(response)
    end

    def get(path)
      response = with_error_handling { RestClient.get(full_url(path), get_headers) }
      JSON.parse(response)
    end

    def delete(path)
      response = with_error_handling { RestClient.delete(full_url(path), get_headers) }
      JSON.parse(response)
    end

    private

    def full_url(path)
      "#{base_url}#{path}"
    end

    def with_error_handling
      yield
    rescue => e
      # By the way, this is a really bad idea.
      # See: https://www.relishapp.com/womply/ruby-style-guide/docs/exceptions
      # The exceptions should be enumerated. Not all exceptions are going
      # to be parsable by JSON. The only one that should be captured are the
      # are the HTTP Client responses.
      case e.response.code
      when 400
        return e.response
      when 401
        return e.response
      when 409
        return e.response
      when 500
        return e.response
      when 405
        return handle_method_not_allowed
      when 502
        #Raise a gateway error
        return handle_gateway_error
      when 504
        #Raise a timeout error
        return handle_timeout_error
      else
        #Raise a generic error
        return handle_unknown_error
      end
    end

    def handle_method_not_allowed
      return {'success' => false, 'reason' => 'The method is not allowed. Check your id parameters.'}.to_json
    end

    def handle_gateway_error
      return {'success' => false, 'reason' => 'The gateway appears to be down.  Check synapsepay.com or try again later.'}.to_json
    end

    def handle_timeout_error
      return {'success' => false, 'reason' => 'A timeout has occurred.'}.to_json
    end


    def handle_unknown_error
      return {'success' => false, 'reason' => 'Unknown error in library. Contact synapsepay.'}.to_json
    end
  end
end
