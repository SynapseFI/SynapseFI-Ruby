module SynapsePayRest
  class WireNode < BaseNode
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
        self.new(
          user:            user,
          type:            response['type'],
          id:              response['_id'],
          is_active:       response['is_active'],
          account_id:      response['info']['account_id'],
          balance:         response['info']['balance']['amount'],
          currency:        response['info']['balance']['currency'],
          name_on_account: response['info']['name_on_account'],
          nickname:        response['info']['nickname'],
          permissions:     response['allowed'],
          supp_id:         response['extra']['supp_id']
        )
      end
    end
  end
end
