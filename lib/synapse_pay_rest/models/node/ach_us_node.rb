module SynapsePayRest
  class AchUsNode < BaseNode
    class << self
      # valid banks: https://synapsepay.com/api/v3/institutions/show
      def create_via_bank_login(user:, bank_name:, username:, password:)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'bank_name must be a String' unless bank_name.is_a?(String)
        raise ArgumentError, 'username must be a String' unless username.is_a?(String)
        raise ArgumentError, 'password must be a String' unless password.is_a?(String)

        payload = payload_for_create_via_bank_login(bank_name: bank_name, username: username, password: password)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        # MFA questions
        if response['mfa']
          create_unverified_node(user, response)
        else
          create_multiple_from_response(user, response['nodes'])
        end
      end

      def payload_for_create(nickname:, account_number:, routing_number:, 
        account_type:, account_class:, **options)
        payload = {
          'type' => 'ACH-US',
          'info' => {
            'nickname'    => nickname,
            'account_num' => account_number,
            'routing_num' => routing_number,
            'type'        => account_type,
            'class'       => account_class
          }
        }
        # optional payload fields
        extra = {}
        extra['supp_id']            = options[:supp_id] if options[:supp_id]
        extra['gateway_restricted'] = options[:gateway_restricted] if options[:gateway_restricted]
        payload['extra'] = extra if extra.any?

        payload
      end

      def payload_for_create_via_bank_login(bank_name:, username:, password:)
        {
          'type' => 'ACH-US',
          'info' => {
            'bank_id'   => username,
            'bank_pw'   => password,
            'bank_name' => bank_name
          }
        }
      end
      
      def create_unverified_node(user, response)
        UnverifiedNode.new(
          user:             user,
          mfa_access_token: response['mfa']['access_token'],
          mfa_message:      response['mfa']['message'],
          mfa_verified:     false
        )
      end
    end

    def verify_microdeposits(amount1:, amount2:)
      [amount1, amount2].each do |arg|
        raise ArgumentError, "#{arg} must be float" unless arg.is_a?(Float)
      end

      payload = verify_microdeposits_payload(amount1: amount1, amount2: amount2)
      response = user.client.nodes.patch(node_id: id, payload: payload)
      @permission = response['allowed']
      self
    end

    private

    def verify_microdeposits_payload(amount1:, amount2:)
      {'micro' => [amount1, amount2]}
    end
  end
end
