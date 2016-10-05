module SynapsePayRest
  class AchUsNode < BaseNode
    attr_reader 
    # TODO: add error message when trying to perform methods on unverified node
    class << self
      # TODO: validate bank_name in supported banks
      # https://synapsepay.com/api/v3/institutions/show
      def create_via_bank_login(user:, bank_name:, username:, password:)
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

    # TODO: raise error if already verified
    # TODO: raise error if too many attempts
    # TODO: validate inputs as floats
    def verify_microdeposits(amount1:, amount2:)
      payload = verify_microdeposits_payload(amount1: amount1, amount2: amount2)
      response = user.client.nodes.patch(node_id: id, payload: payload)
      @permissions = response['allowed']
      self
    end

    private

    def verify_microdeposits_payload(amount1:, amount2:)
      {
        'micro' => [amount1, amount2]
      }
    end
  end
end
