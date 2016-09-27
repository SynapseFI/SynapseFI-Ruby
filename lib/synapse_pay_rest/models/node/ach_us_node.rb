module SynapsePayRest
  class AchUsNode < Node
    attr_reader 

    class << self
      def payload_for_create(nickname:, account_number:, routing_number:, 
        account_type:, account_class:, **options)
        payload = {
          'type' => 'ACH-US',
          'info' => {
            'nickname'    => nickname,
            'account_num' => account_number,
            'routing_num' => routing_number,
            'type'        => account_type,
            'class'       => account_class
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
        binding.pry
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
          allowed:         node_data['allowed'],
          supp_id:         node_data['extra']['supp_id']
        )
        binding.pry
        user.nodes << node
        node
      end

      def create_via_login()
      end
    end

    def verify_mfa
    end
  end
end
