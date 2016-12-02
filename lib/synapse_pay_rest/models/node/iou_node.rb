module SynapsePayRest
  # Non-USD payments can be tracked using the IOU node type. This can be 
  # anything (e.g. another currency or commodity).
  class IouNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, currency:, **options)
        args = {
          type: 'IOU',
          nickname: nickname,
          currency: currency
        }.merge(options)
        super(args)
      end
    end
  end
end
