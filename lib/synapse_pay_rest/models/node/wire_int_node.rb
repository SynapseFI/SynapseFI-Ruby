module SynapsePayRest
  # Represents a non-US account for wire payments.
  class WireIntNode < WireNode
    class << self
      private 

      def payload_for_create(nickname:, bank_name:, account_number:, swift:,
        name_on_account:, address:, **options)
        args = {
          type: 'WIRE-INT',
          nickname: nickname,
          bank_name: bank_name,
          account_number: account_number,
          name_on_account: name_on_account,
          address: address
        }.merge(options)
        payload = super(args)
        payload['info']['swift'] = swift
        payload
      end
    end
  end
end
