require 'mime-types'
require 'base64'
require 'open-uri'

module SynapsePayRest
  # Wrapper class for /users endpoints
  class Users
    # Valid optional args for #get
    # @todo Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:query, :page, :per_page, :full_dehydrate].freeze

    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end

    # Sends a GET request to /users endpoint and returns the response. Queries a
    # specific user_id if user_id supplied, else queries all users. 
    # 
    # @param user_id [String,void] id of the user
    # @param query [String] (optional) response will be filtered to 
    #   users with matching name/email
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # @param full_dehydrate [String, String] (optional) response will inclulde all KYC info on user
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    # 
    # @todo Probably should use CGI or RestClient's param builder instead of
    # rolling our own, probably error-prone and untested version
    # https://github.com/rest-client/rest-client#usage-raw-url
    def get(user_id: nil, **options)
      path = user_path(user_id: user_id)

      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    # Sends a POST request to /users endpoint to create a new user, and returns
    # the response.
    # 
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/create-a-user payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def create(payload:)
      client.post(user_path, payload)
    end

    # Sends a POST request to /oauth/:user_id endpoint to obtain a new oauth key
    # and update the client's headers, and returns the response
    # 
    # @param user_id [String]
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/get-oauth_key-refresh-token payload structure
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def refresh(user_id:, payload:)
      path = "/oauth/#{user_id}"
      response = client.post(path, payload)
      client.update_headers(oauth_key: response['oauth_key']) if response['oauth_key']
      response
    end

    # Sends a PATCH request to /users endpoint, updating the current user,
    # which can also include adding/updating user CIP documents, and returns the response.
    # 
    # @param payload [Hash]
    # @see https://docs.synapsepay.com/docs/update-user payload structure for
    #   updating user
    # @see https://docs.synapsepay.com/docs/adding-documents payload structure
    #   for adding documents to user
    # @see https://docs.synapsepay.com/docs/updating-existing-document payload
    #   structure for updating user's existing documents
    # 
    # @raise [SynapsePayRest::Error] may return subclasses of error based on 
    # HTTP response from API
    # 
    # @return [Hash] API response
    def update(user_id:, payload:)
      path = user_path(user_id: user_id)
      client.patch(path, payload)
    end
    # Alias for #update (legacy name)
    alias_method :answer_kba, :update
    # Alias for #update (legacy name)
    alias_method :add_doc, :update

    # Converts a file to base64 for use in payloads for adding physical documents.
    # 
    # @param file_path [String]
    # @param file_type [String,void] (optional) MIME type of file (will attempt
    #   to autodetect if nil)
    # 
    # @return [String] base64 encoded file
    def encode_attachment(file_path:, file_type: nil)
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

    # Detects the file type of the file and calls #attach_file_with_file_type
    # on it.
    # 
    # @param file_path [String]
    # @deprecated Use #update with KYC 2.0 payload instead.
    def attach_file(user_id:, file_path:)
      warn caller.first + " DEPRECATION WARNING: #{self.class}##{__method__} is deprecated. Use #update with encode_attachment instead."

      file_contents = open(file_path) { |f| f.read }
      content_types = MIME::Types.type_for(file_path)
      file_type = content_types.first.content_type if content_types.any?
      if file_type.nil?
        raise('File type not found. Use attach_file_with_file_type(user_id: <user_id>, file_path: <file_path>, file_type: <file_type>)')
      else
        attach_file_with_file_type(user_id: user_id, file_path: file_path, file_type: file_type)
      end
    end

    # Converts a file to base64 and sends it to the API using deprecated KYC 1.0 
    # call.
    # 
    # @param file_path [String]
    # @param file_type [String] MIME type
    # @deprecated Use #update with KYC 2.0 payload instead.
    def attach_file_with_file_type(user_id:, file_path:, file_type:)
      warn caller.first + " DEPRECATION WARNING: #{self.class}##{__method__} is deprecated. Use #update with encode_attachment instead."

      path = user_path(user_id: user_id)
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

    def user_path(user_id: nil)
      path = "/users"
      path += "/#{user_id}" if user_id
      path
    end
  end
end
