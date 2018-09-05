module SynapsePayRest
  # Represents a non-US account for wire payments.
  class WireIntNode < BaseNode
    class << self
      private 

      def payload_for_create(nickname:, bank_name:, account_number:, swift:,
        name_on_account:, address:, **options)
        args = {
          type: 'WIRE-INT',
          nickname: nickname,
          bank_name: bank_name,
          account_number: account_number,
          swift: swift,
          name_on_account: name_on_account,
          address: address
        }.merge(options)
        super(args)
      end
    end
  end
end
