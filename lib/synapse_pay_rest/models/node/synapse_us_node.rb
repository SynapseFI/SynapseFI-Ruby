module SynapsePayRest
  # Represents a Synapse node allowing any user to hold funds. You can use this
  # node as a wallet, an escrow account or something else along those lines.
  class SynapseUsNode < SynapseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'SYNAPSE-US',
          nickname: nickname
        }.merge(options)
        payload = super(args)
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
