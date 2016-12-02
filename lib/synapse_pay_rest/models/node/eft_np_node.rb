module SynapsePayRest
  # Represents a Nepali bank account for EFT credits.
  class EftNpNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, bank_name:, account_number:, **options)
        args = {
          type: 'EFT-NP',
          nickname: nickname,
          bank_name: bank_name,
          account_number: account_number
        }.merge(options)
        super(args)
      end
    end
  end
end
