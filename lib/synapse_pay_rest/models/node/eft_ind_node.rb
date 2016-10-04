module SynapsePayRest
  class EftIndNode < EftNode
    class << self
      def payload_for_create(nickname:, account_number:, ifsc:, **options)
        args = {
          type: 'EFT-IND',
          nickname: nickname,
          account_number: account_number
        }.merge(options)
        payload = super(args)
        payload['info']['ifsc'] = ifsc
        payload
      end
    end
  end
end
