module SynapsePayRest
  # A custody node allowing any user to hold funds in custodial accont.
  class CustodyUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'CUSTODY-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
