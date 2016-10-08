module SynapsePayRest
  # Represents a US bank account for processing ACH payments. Can be added by
  # account/routing number or via bank login for selected banks (recommended).
  # 
  # @see https://docs.synapsepay.com/docs/node-resources nodes documentation
  # @see https://synapsepay.com/api/v3/institutions/show valid banks for login
  class AchUsNode < BaseNode
    class << self
      # Creates an ACH-US node via bank login, belonging to user supplied.
      # 
      # @param user [SynapsePayRest::User] the user to whom the node belongs 
      # @param bank_name [String] 
      # @see https://synapsepay.com/api/v3/institutions/show valid bank_name options
      # @param username [String] user's bank login username
      # @param password [String] user's bank login password
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [Array<SynapsePayRest::AchUsNode>] may contain multiple nodes (checking and/or savings)s
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

      private

      # Converts args into payload for request JSON.
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
      
      # Creates a SynapsePayRest::UnverifiedNode when bank responds with MFA
      # questions.
      def create_unverified_node(user, response)
        UnverifiedNode.new(
          user:             user,
          mfa_access_token: response['mfa']['access_token'],
          mfa_message:      response['mfa']['message'],
          mfa_verified:     false
        )
      end
    end

    # Verifies the microdeposit amounts sent to the user's account to verify
    # a node added by account and routing number. Node will be locked if max
    # tries exceeded.
    # 
    # @param amount1 [Float]
    # @param amount2 [Float]
    # 
    # @raise [SynapsePayRest::Error] if wrong guess or HTTP error
    # 
    # @return [:successs] if successful
    def verify_microdeposits(amount1:, amount2:)
      [amount1, amount2].each do |arg|
        raise ArgumentError, "#{arg} must be float" unless arg.is_a?(Float)
      end

      payload = verify_microdeposits_payload(amount1: amount1, amount2: amount2)
      response = user.client.nodes.patch(node_id: id, payload: payload)
      @permission = response['allowed']
      :success
    end

    private

    # Converts the data to hash format for request JSON.
    def verify_microdeposits_payload(amount1:, amount2:)
      {'micro' => [amount1, amount2]}
    end
  end
end
