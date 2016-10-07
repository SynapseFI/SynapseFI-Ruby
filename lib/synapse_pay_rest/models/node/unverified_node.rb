module SynapsePayRest
  # Represents a node that has not yet been created due to pending bank login
  # MFA questions.
  class UnverifiedNode
    # @!attribute [r] user
    #   @return [SynapsePayRest::User] the user to whom the node belongs
    # @!attribute [r] mfa_access_token
    #   @return [String] access token that must be included in the response (handled automatically)
    # @!attribute [r] mfa_message
    #   @return [String] question or MFA prompt from bank that must be answered
    # @!attribute [r] mfa_verified
    #   @return [Boolean] whether the node is verified yet
    attr_reader :user, :mfa_access_token, :mfa_message, :mfa_verified

    def initialize(user:, mfa_access_token:, mfa_message:, mfa_verified:)
      @user             = user
      @mfa_access_token = mfa_access_token
      @mfa_message      = mfa_message
      @mfa_verified     = mfa_verified
    end

    # Allows the user to submit an answer to the bank in response to mfa_message.
    # 
    # @param answer [String] the user's answer to the mfa_message asked by the bank
    # 
    # @raise [SynapsePayRest::Error] if incorrect answer
    # 
    # @return [Array<SynapsePayRest::AchUsNode>] may contain multiple nodes (checking and/or savings)s
    # 
    # @todo IMPORTANT! Need to handle when multiple MFA's triggered.
    # @todo make a new Error subclass for incorrect MFA
    def answer_mfa(answer:)
      payload = payload_for_answer_mfa(answer: answer)
      response = user.client.nodes.post(payload: payload)
      
      if response['error_code'] == '0'
        # correct answer
        @mfa_verified = true
        AchUsNode.create_multiple_from_response(user, response['nodes'])
      else
        # wrong answer
        args = {
          message: 'incorrect bank login mfa answer',
          code: response['http_code'], 
          response: response
        }
        raise SynapsePayRest::Error, args
      end
    end

    private

    def payload_for_answer_mfa(answer:)
      {
        'access_token' => mfa_access_token,
        'mfa_answer'   => answer
      }
    end
  end
end
