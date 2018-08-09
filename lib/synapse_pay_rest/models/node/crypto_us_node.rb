module SynapsePayRest
  # A BTC node allowing any user to hold funds in BTC.
  class CryptoUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, **options)
        args = {
          type: 'CRYPTO-US',
          nickname: nickname
        }.merge(options)
        super(args)
      end
    end
  end
end
