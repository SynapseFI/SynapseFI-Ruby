module SynapsePayRest
  # 
  class IbDepositUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'IB-DEPOSIT-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
