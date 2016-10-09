module SynapsePayRest
  # Represents a US bank account for processing wire payments.
  class WireUsNode < WireNode
    class << self
      private

      def payload_for_create(nickname:, bank_name:, account_number:, routing_number:,
        name_on_account:, address:, **options)
        args = {
          type: 'WIRE-US',
          nickname: nickname,
          bank_name: bank_name,
          account_number: account_number,
          routing_number: routing_number,
          name_on_account: name_on_account,
          address: address
        }.merge(options)
        
        super(args)
      end
    end
  end
end
