module SynapsePayRest
  # Represents a Synapse node allowing any user to hold Indian Rupees.
  class SynapseIndNode < SynapseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'SYNAPSE-IND',
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
