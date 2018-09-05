module SynapsePayRest
  class SubaccountUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'SUBACCOUNT-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
