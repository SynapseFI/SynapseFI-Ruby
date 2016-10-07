module SynapsePayRest
  # Represents a Nepali bank account for EFT credits.
  class EftNpNode < EftNode
    class << self
      private

      def payload_for_create(nickname:, bank_name:, account_number:, **options)
        args = {
          type: 'EFT-NP',
          nickname: nickname,
          account_number: account_number
        }.merge(options)
        payload = super(args)
        payload['info']['bank_name'] = bank_name
        payload
      end
    end
  end
end
