module SynapsePayRest
  # A Synapse node allowing any user to hold funds. You can use this node for
  # storing reserves with Synapse.
  class ReserveUsNode < BaseNode
    class << self
      private

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
