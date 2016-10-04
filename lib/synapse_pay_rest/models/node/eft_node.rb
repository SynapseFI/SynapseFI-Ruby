module SynapsePayRest
  class EftNode < BaseNode
    class << self
      def payload_for_create(type:, nickname:, account_number:, **options)
        payload = {
          'type' => type,
          'info' => {
            'nickname'        => nickname,
            'account_num'     => account_number
          }
        }

        # optional payload fields
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?
        payload
      end
    end
  end
end
