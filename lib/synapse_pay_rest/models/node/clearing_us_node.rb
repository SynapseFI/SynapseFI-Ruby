module SynapsePayRest
  # 
  class ClearingUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'CLEARING-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
