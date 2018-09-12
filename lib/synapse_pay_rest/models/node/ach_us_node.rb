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
      # @return [Array<SynapsePayRest::AchUsNode>] may contain multiple nodes (checking and/or savings)
      def create_via_bank_login(user:, bank_name:, username:, password:)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'bank_name must be a String' unless bank_name.is_a?(String)
        raise ArgumentError, 'username must be a String' unless username.is_a?(String)
        raise ArgumentError, 'password must be a String' unless password.is_a?(String)

        payload = payload_for_create_via_bank_login(bank_name: bank_name, username: username, password: password)
        response = user.client.nodes.add(user_id: user.id, payload: payload)
        # MFA questions
        if response['mfa']
          create_unverified_node(user, response)
        else
          multiple_from_response(user, response['nodes'])
        end
      end

      # Creates an Unverified Node Class node via access token, belonging to this user
      # 
      # @param user [SynapsePayRest::User] the user to whom the node belongs 
      # @param access_token [String] user's access token 
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [<SynapsePayRest::UnverifiedNode>]
      def create_via_bank_login_mfa(user:, access_token:)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'access_token must be a String' unless access_token.is_a?(String)
        payload = payload_for_create_via_bank_login_mfa(access_token: access_token)
        create_unverified_node(user, payload)
      end

      private

      # Converts args into payload for request JSON.
      def payload_for_create(nickname:, account_number:, routing_number:, 
        account_type:, account_class:, **options)
        args = {
          type: 'ACH-US',
          nickname:       nickname,
          account_number: account_number,
          routing_number: routing_number,
          account_type:   account_type,
          account_class:  account_class
        }.merge(options)
        super(args)
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

      def payload_for_create_via_bank_login_mfa(access_token:)
        {
          'mfa' => {
              'access_token' => access_token,
              'message' => ''
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
    # @return [SynapsePayRest::AchUsNode]
    def verify_microdeposits(amount1:, amount2:)
      [amount1, amount2].each do |arg|
        raise ArgumentError, "#{arg} must be float" unless arg.is_a?(Float)
      end

      payload = verify_microdeposits_payload(amount1: amount1, amount2: amount2)
      response = user.client.nodes.patch(user_id: user.id, node_id: id, payload: payload)
      self.class.from_response(user, response)
    end
    
    # Reinitiates microdeposits on a node
    # 
    # 
    # @raise [SynapsePayRest::Error] if wrong guess or HTTP error
    # 
    # @return [SynapsePayRest::AchUsNode]
    def resend_micro()
      response = user.client.nodes.resend_micro(user_id: user.id, node_id: id)
      self.class.from_response(user, response)
    end
    

    private

    # Converts the data to hash format for request JSON.
    def verify_microdeposits_payload(amount1:, amount2:)
      {'micro' => [amount1, amount2]}
    end

  end
end
