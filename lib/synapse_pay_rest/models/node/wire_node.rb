module SynapsePayRest
  class WireNode < BaseNode
    class << self
      def payload_for_create(nickname:, bank_name:, account_number:, routing_number:,
        name_on_account:, address:, **options)
        payload = {
          'info' => {
            'nickname'        => nickname,
            'name_on_account' => name_on_account,
            'account_num'     => account_number,
            'routing_num'     => routing_number,
            'bank_name'       => bank_name,
            'address'         => address,
          }
        }
        if self == WireUsNode
          payload['type'] = 'WIRE-US'
        elsif self == WireIntNode
          payload['type'] = 'WIRE-INT'
        end
        # optional payload fields
        payload['info']['swift'] = options[:swift] if options[:swift]
        correspondent_info = {}
        correspondent_info['routing_num'] = options[:correspondent_routing_number] if options[:correspondent_routing_number]
        correspondent_info['bank_name']   = options[:correspondent_bank_name] if options[:correspondent_bank_name]
        correspondent_info['address']     = options[:correspondent_address] if options[:correspondent_address]
        correspondent_info['swift']       = options[:correspondent_swift] if options[:correspondent_swift]
        payload['correspondent_info'] = correspondent_info if correspondent_info.any?
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload[:extra] = extra if extra.any?

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
