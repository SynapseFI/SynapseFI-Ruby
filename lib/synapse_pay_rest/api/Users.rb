require 'mime-types'
require 'base64'
require 'open-uri'

module SynapsePayRest
  class Users

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create_user_path(user_id: nil)
      path = '/users'
      if user_id
        path += '/%s' %user_id
      end
      return path
    end

    def refresh(payload: raise("payload is required"))
      path = '/oauth/%s' % @client.user_id
      response = @client.post(path, payload)
      if response.has_key?('oauth_key')
        @client.update_headers(oauth_key: response['oauth_key'])
      end
      return response
    end

    def get(user_id: nil, query: nil, page: nil, per_page: nil)
      if user_id
        path = create_user_path(user_id: user_id)
        response = @client.get(path)
        if response.has_key?('_id')
          @client.update_headers(user_id: response['_id'])
        end
      elsif query
        path += '?query=%s' %query
        if page
          path += '&page=%s' %page
        end
        if per_page
          path += '&per_page=%s' %per_page
        end
      elsif page
        path += '?page=%s' %page
        if per_page
          path += '&per_page=%s' %per_page
        end
      elsif per_page
        path += '?page=%s' %per_page
      else
        path = create_user_path()
      end
      response = @client.get(path)
      return response
    end

    def update(payload: raise("payload is required"))
      path = create_user_path(user_id: @client.user_id)
      response = @client.patch(path, payload)
      return response
    end

    def create(payload: raise("payload is required"))
      path = create_user_path()
      response = @client.post(path, payload)
      return response
    end

    def add_doc(payload: raise("payload is required"))
      path = create_user_path(user_id: @client.user_id)
      response = @client.patch(path, payload)
      return response
    end

    def answer_kba(payload: raise("payload is required"))
      path = create_user_path(user_id: @client.user_id)
      response = @client.patch(path, payload)
      return response
    end

    def attach_file(file_path: raise("file_path is required"))
      path = create_user_path(user_id: @client.user_id)
      file_contents = open(file_path) { |f| f.read }
      file_type = MIME::Types.type_for(file_path).first.content_type
      mime_padding = 'data:' + file_type + ';base64,'
      encoded = Base64.encode64(file_contents)
      base64_attachment = mime_padding + encoded
      payload = {
        'doc' => {
          'attachment' => base64_attachment
        }
      }
      response = @client.patch(path, payload)
      return response
    end
  end
end
