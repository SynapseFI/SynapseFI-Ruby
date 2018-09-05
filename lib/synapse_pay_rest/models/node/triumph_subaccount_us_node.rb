module SynapsePayRest
  # Represents a subaccount inside a FBO account at Triumph Bank.
  # 
  # @deprecated
  class TriumphSubaccountUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'TRIUMPH-SUBACCOUNT-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
