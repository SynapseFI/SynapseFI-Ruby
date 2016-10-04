module SynapsePayRest
  class WireUsNode < WireNode
    class << self
      def payload_for_create(nickname:, bank_name:, account_number:, routing_number:,
        name_on_account:, address:, **options)
        args = {
          type: 'WIRE-US',
          nickname: nickname,
          bank_name: bank_name,
          account_number: account_number,
          routing_number: routing_number,
          name_on_account: name_on_account,
          address: address,
          options: options
        }
        super(args.merge(options))
      end
    end
  end
end
