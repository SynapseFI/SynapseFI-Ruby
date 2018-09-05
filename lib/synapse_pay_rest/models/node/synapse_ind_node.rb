module SynapsePayRest
  # Represents a Synapse node allowing any user to hold Indian Rupees.
  # 
  # @deprecated
  class SynapseIndNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'SYNAPSE-IND',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
