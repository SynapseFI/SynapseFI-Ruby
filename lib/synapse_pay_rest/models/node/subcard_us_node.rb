module SynapsePayRest

  class SubcardUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, document_id:, card_type:, **options)
        args = {
          type: 'SUBCARD-US',
          nickname: nickname,
          document_id: document_id,
          card_type: card_type,
        }.merge(options)
        super(args)
      end
    end

      def update_preferences(**options)
        if options.empty?
          raise ArgumentError, 'must provide some key-value pairs to update'
        end
        payload = payload_for_preferences(options)
        response = user.client.nodes.patch(user_id: user.id, node_id: id, payload: payload)
        self.class.from_response(user, response)
      end

      def update_allowed(allowed:)
        if allowed.empty?
          raise ArgumentError, 'must provide some key-value pairs to update'
        end
        payload = { 'allowed': allowed }
        response = user.client.nodes.patch(user_id: user.id, node_id: id, payload: payload)
        self.class.from_response(user, response)
      end

      private
      
      def payload_for_preferences(**options)
        payload = {
            'preferences' => {}
        }
        if options[:allow_foreign_transactions]
          payload['preferences']['allow_foreign_transactions'] = options[:allow_foreign_transactions]
        end

        if options[:atm_withdrawal_limit]
          payload['preferences']['atm_withdrawal_limit'] = options[:atm_withdrawal_limit]
        end

        if options[:max_pin_attempts]
          payload['preferences']['max_pin_attempts'] = options[:max_pin_attempts]
        end
        
        if options[:pos_withdrawal_limit]
          payload['preferences']['pos_withdrawal_limit'] = options[:pos_withdrawal_limit]
        end

        if options[:security_alerts]
          payload['preferences']['security_alerts'] = options[:security_alerts]
        end

        payload
      end
  end
end