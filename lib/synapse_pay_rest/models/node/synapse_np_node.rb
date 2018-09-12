module SynapsePayRest
  # Represents a Synapse node allowing any user to hold Nepali Rupees.
  # 
  # @deprecated
  class SynapseNpNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'SYNAPSE-NP',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
