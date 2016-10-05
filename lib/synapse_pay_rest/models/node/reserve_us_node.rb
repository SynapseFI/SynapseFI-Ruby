module SynapsePayRest
  class ReserveUsNode < BaseNode
    class << self
      def payload_for_create(nickname:, **options)
        payload = {
          'type' => 'RESERVE-US',
          'info' => {
            'nickname'        => nickname,
          }
        }
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?
        payload
      end
    end
  end
end
