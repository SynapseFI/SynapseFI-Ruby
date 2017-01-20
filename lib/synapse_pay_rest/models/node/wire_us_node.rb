module SynapsePayRest
  # Represents a US bank account for processing wire payments.
  class WireUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, account_number:, routing_number:,
        name_on_account:, **options)
        args = {
          type: 'WIRE-US',
          nickname: nickname,
          account_number: account_number,
          routing_number: routing_number,
          name_on_account: name_on_account
        }.merge(options)
        super(args)
      end
    end
  end
end
