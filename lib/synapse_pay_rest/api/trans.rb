module SynapsePayRest
  class Trans

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create_transaction_path(node_id: raise("node_id is required"), trans_id: nil)
      path = '/users/' + @client.user_id + '/nodes/' + node_id + '/trans'
      if trans_id
        path += '/' + trans_id
      end
      return path
    end

    def create(node_id: raise("node_id is required"), payload: raise("payload is required"))
      path = create_transaction_path(node_id: node_id)
      response = @client.post(path, payload)
      return response
    end

    def update(node_id: raise("node_id is required"), trans_id: raise("trans_id is required"), payload: raise("payload is required"))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      response = @client.patch(path, payload)
      return response
    end

    def get(node_id: raise("node_id is required"), trans_id: nil, page: nil)
      if trans_id
        path = create_transaction_path(node_id: node_id, trans_id: trans_id)
        response = @client.get(path)
        return response
      else
        path = create_transaction_path(node_id: node_id)
        if page
          path += '?page=%d' %page
        end
        response = @client.get(path)
        return response
      end
    end

    def delete(node_id: raise("node_id is required"), trans_id: raise("trans_id is required"))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      response = @client.delete(path)
      return response
    end
  end
end
