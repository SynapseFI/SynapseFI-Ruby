module SynapsePayRest
  # Factory for BaseNode subclasses.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode
  module Node

    # Node type to node class mappings.
    NODE_TYPES_TO_CLASSES = {
      'ACH-US'      => AchUsNode,
      'EFT-NP'      => EftNpNode,
      'EFT-IND'     => EftIndNode,
      'IOU'         => IouNode,
      'RESERVE-US'  => ReserveUsNode,
      'SYNAPSE-IND' => SynapseIndNode,
      'SYNAPSE-NP'  => SynapseNpNode,
      'SYNAPSE-US'  => SynapseUsNode,
      'WIRE-INT'    => WireIntNode,
      'WIRE-US'     => WireUsNode
    }.freeze

    class << self
      # Queries the API for a node with the supplied id belong to the supplied user,
      # and returns a node instance from the response data.
      # 
      # @param user [SynapsePayRest::User]
      # @param id [String] id of the node to find
      # 
      # @raise [SynapsePayRest::Error] if HTTP error
      # 
      # @return [SynapsePayRest::BaseNode] subclass depends on node type
      def find(user:, id:)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        user.authenticate
        response = user.client.nodes.get(user_id: user.id, node_id: id)
        create_from_response(user, response)
      end

      # Queries the API for all nodes belonging to the supplied user (with optional
      # filters) and returns them as node instances.
      # 
      # @param user [SynapsePayRest::User]
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # @param type [String] (optional)
      # @see https://docs.synapsepay.com/docs/node-resources node types
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [Array<SynapsePayRest::BaseNode>] subclass depends on node types
      def all(user:, page: nil, per_page: nil, type: nil)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end
        unless type.nil? || NODE_TYPES_TO_CLASSES.keys.include?(type)
          raise ArgumentError, "type must be nil or in #{NODE_TYPES_TO_CLASSES.keys}"
        end

        user.authenticate
        response = user.client.nodes.get(page: page, per_page: per_page, type: type)
        create_multiple_from_response(user, response['nodes'])
      end

      # Queries the API for all nodes belonging to the supplied user (with optional
      # filters) and matching the given type.
      # 
      # @param user [SynapsePayRest::User]
      # @param type [String]
      # @see https://docs.synapsepay.com/docs/node-resources node types
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [Array<SynapsePayRest::BaseNode>] BaseNode will be subclass corresponding to type arg
      def by_type(user:, type:, page: nil, per_page: nil)
        all(user: user, page: page, per_page: per_page, type: type)
      end

      private

      # determines the proper node type to instantiate from the response
      # implemented differently in each BaseNode subclass
      def create_from_response(user, response)
        klass = NODE_TYPES_TO_CLASSES.fetch(response['type'])
        klass.create_from_response(user, response)
      end

      def create_multiple_from_response(user, response)
        return [] if response.empty?
        response.map { |node_data| create_from_response(user, node_data)}
      end
    end
  end
end
