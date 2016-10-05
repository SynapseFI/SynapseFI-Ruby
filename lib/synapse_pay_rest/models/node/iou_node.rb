module SynapsePayRest
  class IouNode < BaseNode
    class << self
      def payload_for_create(nickname:, currency:, **options)
        payload = {
          'type' => 'IOU',
          'info' => {
            'nickname' => nickname,
            'balance'  => {
              'currency' => currency
            }
          }
        }
        # optional payload fields
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?
        payload
      end
    end
  end
end
