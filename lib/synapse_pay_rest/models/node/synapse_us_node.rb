module SynapsePayRest
  class SynapseUsNode < SynapseNode
    class << self
      def payload_for_create(nickname:, **options)
        payload = {
          'type' => 'SYNAPSE-US',
          'info' => {
            'nickname' => nickname
          }
        }
        # optional payload fields
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?

        payload
      end

      def create_from_response(user, response)
        node_data = response['nodes'].last
        node = self.new(
          user: user,
          type: 'SYNAPSE-US',
          id:              node_data['_id'],
          is_active:       node_data['is_active'],
          account_id:      node_data['info']['account_id'],
          balance:         node_data['info']['balance']['amount'],
          currency:        node_data['info']['balance']['currency'],
          name_on_account: node_data['info']['name_on_account'],
          nickname:        node_data['info']['nickname'],
          permissions:     node_data['allowed'],
          supp_id:         node_data['extra']['supp_id']
        )
        user.nodes << node
        node
      end
    end
  end
end
