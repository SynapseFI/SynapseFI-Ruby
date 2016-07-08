require 'rest-client'

module SynapsePayRest
  class HTTPClient

    attr_accessor :base_url
    attr_accessor :options
    attr_accessor :headers
    attr_accessor :user_id

    def initialize(options, base_url, user_id: nil)
      @options = options
      user = '|%s' %options['fingerprint']
      if options.has_key?('oauth_key')
        user = '%s|%s' % [options['oauth_key'], options['fingerprint']]
      end
      gateway = '%s|%s' % [options['client_id'], options['client_secret']]
      @headers = {
        :content_type => :json,
        :accept => :json,
        'X-SP-GATEWAY' => gateway,
        'X-SP-USER' => user,
        'X-SP-USER-IP' => options['ip_address']
      }
      @base_url = base_url
      # RestClient.log = 'stdout'
      @user_id = user_id
    end

    def update_headers(user_id: nil, oauth_key: nil, fingerprint: nil, client_id: nil, client_secret: nil, ip_address: nil)
      if user_id
        @user_id = user_id
      end
      if oauth_key and !fingerprint
        @headers['X-SP-USER'] = '%s|%s' % [oauth_key, @options['fingerprint']]
      elsif oauth_key and fingerprint
        @headers['X-SP-USER'] = '%s|%s' % [oauth_key, fingerprint]
      end

      if client_id and !client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [client_id, @options['client_secret']]
      elsif client_id and client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [client_id, client_secret]
      elsif !client_id and client_secret
        @headers['X-SP-GATEWAY'] = '%s|%s' % [@options['client_id'], client_secret]
      end

      if ip_address
        @headers['X-SP-USER-IP'] = ip_address
      end
    end


    def post(path, payload)
      binding.pry
      url = base_url + path
      response = begin
                   RestClient.post(url,
                                   payload.to_json,
                                   @headers)
                 rescue Exception => e
                   return JSON.parse(e.response)
                 end
      return JSON.parse(response)
    end

    def patch(path, payload)
      binding.pry
      url = base_url + path
      response = begin
                   RestClient.patch(url,
                                    payload.to_json,
                                    @headers)
                 rescue Exception => e
                   puts url
                   return JSON.parse(e.response)
                 end
      return JSON.parse(response)
    end

    def get(path)
      binding.pry
      url = base_url + path
      response = begin
                   RestClient.get(url,
                                  @headers)
                 rescue Exception => e
                   return JSON.parse(e.response)
                 end
      return JSON.parse(response)
    end

    def delete(path)
      url = base_url + path
      response = begin
                   RestClient.delete(url,
                                     @headers)
                 rescue Exception => e
                   return JSON.parse(e.response)
                 end
      return JSON.parse(response)
    end
  end
end
