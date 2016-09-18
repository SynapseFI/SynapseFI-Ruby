module SynapsePayRest
  # rename this
  class Trans
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create_transaction_path(node_id: raise("node_id is required"), trans_id: nil)
      path = ['/users', client.user_id, 'nodes', node_id, 'trans' ]
      path << trans_id if trans_id
      return path.join('/')
    end

    def create(node_id: raise("node_id is required"), payload: raise("payload is required"))
      path = create_transaction_path(node_id: node_id)
      client.post(path, payload)
    end

    def update(node_id: raise("node_id is required"), trans_id: raise("trans_id is required"), payload: raise("payload is required"))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.patch(path, payload)
    end

    def get(node_id: raise("node_id is required"), trans_id: nil, page: nil)
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      # This part really should just be a generic params generator
      path += "?page=#{page}" if page
      client.get(path)
    end

    def delete(node_id: raise("node_id is required"), trans_id: raise("trans_id is required"))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.delete(path)
    end
  end
end
