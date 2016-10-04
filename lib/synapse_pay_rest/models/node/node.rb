module SynapsePayRest
  # factory methods
  # TODO: mixin some of these for node classes instead of duplicating
  # TODO: (maybe) write == method to check if nodes have same id
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
        payload = payload_for_create(nickname: nickname, **options)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        create_from_response(user, response['nodes'].first)
      end

      # TODO: allow user or user_id
      def find(user:, id:)
        user.authenticate
        response = user.client.nodes.get(user_id: user.id, node_id: id)
        create_from_response(user, response)
      end

      # TODO: allow user or user_id
      # TODO: validate arguments in valid range / type options
      def all(user:, page: nil, per_page: nil, type: nil)
        user.authenticate
        response = user.client.nodes.get(page: page, per_page: per_page, type: type)
        create_multiple_from_response(user, response['nodes'])
      end

      # TODO: allow user or user_id
      def by_type(user:, type:, page: nil, per_page: nil)
        all(user: user, page: page, per_page: per_page, type: type)
      end

      private

      # determines the proper node type to instantiate from the response
      # #create_from_response is implemented differently in each BaseNode subclass
      def create_from_response(user, response)
        klass = NODE_TYPES_TO_CLASSES[response['type']]
        # TODO: catch error here in case key lookup fails
        klass.create_from_response(user, response)
      end

      def create_multiple_from_response(user, response)
        response.map { |node_data| create_from_response(user, node_data)}
      end
    end
  end
end
