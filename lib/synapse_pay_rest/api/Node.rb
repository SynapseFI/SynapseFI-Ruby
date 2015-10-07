class Node

	attr_accessor :client

	def initialize(client)
		@client = client
	end

	def create_node_path(node_id: nil)
		path = '/users/%s' % @client.user_id + '/nodes'
		if node_id
			path += '/%s' %node_id
		end
		return path
	end

	def add(payload: )
		path = create_node_path()
		response = @client.post(path, payload)
		return response
	end

	def get(node_id: nil, page: nil)
		if node_id
			path = create_node_path(node_id: node_id)
		else
			path = create_node_path()
		end
		if page
			path += '?page=%s' %page
		end
		response = @client.get(path)
		return response
	end

	def verify(node_id: nil, payload: )
		if node_id
			path = create_node_path(node_id: node_id)
			response = @client.patch(path, payload)
			return response
		else
			path = create_node_path()
			response = @client.post(path, payload)
			return response
		end
	end

	def delete(node_id: )
		path = create_node_path(node_id: node_id)
		response = @client.delete(path)
		return response
	end
end