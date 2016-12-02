module SynapsePayRest
  # Represents an Indian bank account for EFT credits.
  # 
  # @deprecated
  class EftIndNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, account_number:, ifsc:, **options)
        payload = {
          type: 'EFT-IND',
          nickname: nickname,
          account_number: account_number,
          ifsc: ifsc
        }.merge(options)
        super(payload)
      end
    end
  end
end
