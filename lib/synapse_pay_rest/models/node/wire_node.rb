module SynapsePayRest
  # Parent of all Wire nodes. Should not be instantiated directly.
  # 
  # @todo Make this a module instead.
  class WireNode < BaseNode
    class << self
      private

      def payload_for_create(type:, nickname:, bank_name:, account_number:, address:,
        name_on_account:, **options)
        payload = {
          'type' => type,
          'info' => {
            'nickname'        => nickname,
            'name_on_account' => name_on_account,
            'account_num'     => account_number,
            'bank_name'       => bank_name,
            'address'         => address,
          }
        }

        # optional payload fields
        payload['info']['routing_num'] = options[:routing_number] if options[:routing_number]
        correspondent_info = {}
        correspondent_info['routing_num'] = options[:correspondent_routing_number] if options[:correspondent_routing_number]
        correspondent_info['bank_name']   = options[:correspondent_bank_name] if options[:correspondent_bank_name]
        correspondent_info['address']     = options[:correspondent_address] if options[:correspondent_address]
        correspondent_info['swift']       = options[:correspondent_swift] if options[:correspondent_swift]
        payload['info']['correspondent_info'] = correspondent_info if correspondent_info.any?
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?
        payload
      end
    end
  end
end
