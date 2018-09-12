module SynapsePayRest
  # A Synapse node allowing any user to hold funds. You can use this node for
  # storing reserves with Synapse.
  class ReserveUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'RESERVE-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
