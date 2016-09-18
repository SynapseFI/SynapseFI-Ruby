module SynapsePayRest
  class Nodes
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create_node_path(node_id: nil)
      path = ['/users', client.user_id, 'nodes' ]
      path << node_id if node_id
      return path.join('/')
    end

    def add(payload: raise("payload is required"))
      path = create_node_path
      client.post(path, payload)
    end

    def get(node_id: nil, page: nil)
      # If node_id is nil then create_node_path will handle it just fine
      path = create_node_path(node_id: node_id)
      path += "?page=#{page}" if page
      client.get(path)
    end

    # separate this into different methods
    def verify(node_id: nil, payload: raise("payload is required"))
      if node_id
        # verify microdeposits
        path = create_node_path(node_id: node_id)
        response = @client.patch(path, payload)
      else
        # verify MFA question(s)
        path = create_node_path
        response = @client.post(path, payload)
      end
      response
    end

    def delete(node_id: raise("node_id is required"))
      path = create_node_path(node_id: node_id)
      client.delete(path)
    end
  end
end
