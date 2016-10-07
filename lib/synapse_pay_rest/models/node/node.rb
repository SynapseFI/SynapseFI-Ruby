module SynapsePayRest
  # factory methods
  # @todo use mixins to remove duplication between Node and BaseNode
  module Node
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
      def create(user:, nickname:, **options)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'nickname must be a String' unless nickname.is_a?(String)

        payload = payload_for_create(nickname: nickname, **options)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        create_from_response(user, response['nodes'].first)
      end

      def find(user:, id:)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        user.authenticate
        response = user.client.nodes.get(user_id: user.id, node_id: id)
        create_from_response(user, response)
      end

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
