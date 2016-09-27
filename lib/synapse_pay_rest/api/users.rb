require 'mime-types'
require 'base64'
require 'open-uri'

module SynapsePayRest
  # TODO: validate payloads are in proper format
  class Users
    # TODO: Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:query, :page, :per_page].freeze

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    # TODO: refactor to automate oauth
    def refresh(payload: raise('payload is required'))
      path = "/oauth/#{@client.user_id}"
      response = @client.post(path, payload)
      client.update_headers(oauth_key: response['oauth_key']) if response['oauth_key']
      response
    end

    def get(user_id: nil, **options)
      path = create_user_path(user_id: user_id)

      # factor single user and all users into separate methods
      if user_id
        response = client.get(path)
        client.update_headers(user_id: response['_id']) if response['_id']
        return response
      end

      # TODO: Should factor this out into HTTPClient and separate args for paginate/search(name/email)/per_page
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      # TODO: Probably should use CGI or RestClient's param builder instead of
      # rolling our own, probably error-prone and untested version
      # https://github.com/rest-client/rest-client#usage-raw-url
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    def update(payload: raise('payload is required'))
      path = create_user_path(user_id: client.user_id)
      response = client.patch(path, payload)
      client.update_headers(user_id: response['_id']) if response['_id']
      response
    end

    def create(payload: raise('payload is required'))
      path = create_user_path
      response = client.post(path, payload)
      client.update_headers(user_id: response['_id']) if response['_id']
      response
    end

    def encode_attachment(file_path: raise('file_path is required'), file_type: nil)
      # try to find file_type
      if file_type.nil?
        content_types = MIME::Types.type_for(file_path)
        file_type = content_types.first.content_type if content_types.any?
      end

      # if file_type not found in previous step
      if file_type.nil?
        raise('File type not found. Specify a file_type argument.')
      end

      file_contents = open(file_path) { |f| f.read }
      encoded = Base64.encode64(file_contents)
      mime_padding = "data:#{file_type};base64,"
      mime_padding + encoded
    end

    # this is just an alias for update. leaving here for legacy users.
    def answer_kba(payload: raise("payload is required"))
      update(payload: payload)
    end

    # this is just an alias for update. leaving here for legacy users.
    def add_doc(payload: raise("payload is required"))
      update(payload: payload)
    end

    # deprecated
    def attach_file(file_path: raise("file_path is required"))
      warn caller.first + " DEPRECATION WARNING: the method #{self.class}##{__method__} is deprecated. Use SynapsePayRest::Users::update with encode_attachment instead."

      file_contents = open(file_path) { |f| f.read }
      content_types = MIME::Types.type_for(file_path)
      file_type = content_types.first.content_type if content_types.any?
      if file_type.nil?
        raise('File type not found. Use attach_file_with_file_type(file_path: <file_path>, file_type: <file_type>)')
      else
        attach_file_with_file_type(file_path: file_path, file_type: file_type)
      end
    end

    # deprecated
    def attach_file_with_file_type(file_path: raise('file_path is required'), file_type: raise('file_type is required'))
      warn caller.first + " DEPRECATION WARNING: the method #{self.class}##{__method__} is deprecated. Use SynapsePayRest::Users::update with encode_attachment instead."

      path = create_user_path(user_id: @client.user_id)
      file_contents = open(file_path) { |f| f.read }
      encoded = Base64.encode64(file_contents)
      mime_padding = "data:#{file_type};base64,"
      base64_attachment = mime_padding + encoded

      payload = {
        'doc' => {
          'attachment' => base64_attachment
        }
      }
      client.patch(path, payload)
    end

    private

    def create_user_path(user_id: nil)
      path = ['/users']
      path << user_id if user_id
      path.join('/')
    end
  end
end
