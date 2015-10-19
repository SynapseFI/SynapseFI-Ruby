require 'mime-types'
require 'base64'
require 'open-uri'

module SynapsePayRest
  class Users
    # Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:query, :page, :per_page].freeze

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create_user_path(user_id: nil)
      path = ['/users']
      path << user_id if user_id
      return path.join('/')
    end

    def refresh(payload: raise("payload is required"))
      path = "/oauth/#{@client.user_id}"
      response = @client.post(path, payload)
      client.update_headers(oauth_key: response['oauth_key']) if response['oauth_key']
      return response
    end

    def get(options = {})
      path = create_user_path(user_id: user_id)

      if options[:user_id]
        response = client.get(path)
        client.update_headers(user_id: response['_id']) if response['_id']
        return response
      end

      # Should factor this out into HTTPClient
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      # Probably should use CGI or RestClient's param builder instead of
      # rolling our own, probably error-prone and untested version
      # https://github.com/rest-client/rest-client#usage-raw-url
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    def update(payload: raise("payload is required"))
      path = create_user_path(user_id: client.user_id)
      client.patch(path, payload)
    end

    def create(payload: raise("payload is required"))
      path = create_user_path()
      client.post(path, payload)
    end

    def add_doc(payload: raise("payload is required"))
      path = create_user_path(user_id: client.user_id)
      client.patch(path, payload)
    end

    def answer_kba(payload: raise("payload is required"))
      path = create_user_path(user_id: client.user_id)
      client.patch(path, payload)
    end

    def attach_file(file_path: raise("file_path is required"))
      path = create_user_path(user_id: @client.user_id)
      file_contents = File.read(file_path)
      file_type = MIME::Types.type_for(file_path).first.content_type
      mime_padding = "data:#{file_type};base64,"
      encoded = Base64.encode64(file_contents)
      base64_attachment = mime_padding + encoded
      payload = {
        'doc' => {
          'attachment' => base64_attachment
        }
      }
      client.patch(path, payload)
    end
  end
end
