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
    #   @todo should be mfa_verified? in Ruby idiom
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
    # @return [Array<SynapsePayRest::AchUsNode>,SynapsePayRest::UnverifiedNode] may contain multiple nodes if successful, else self if new MFA question to answer
    # 
    # @todo make a new Error subclass for incorrect MFA
    def answer_mfa(answer)
      payload  = payload_for_answer_mfa(answer: answer)
      response = user.client.nodes.post(user_id: user.id, payload: payload)
      
      handle_answer_mfa_response(response)
    end

    private

    def payload_for_answer_mfa(answer:)
      {
        'access_token' => mfa_access_token,
        'mfa_answer'   => answer
      }
    end

    # Determines whether the response is successful in verifying the node, has
    # follow-up MFA questions, or failed with an incorrect answer.
    # 
    # @todo Use Error#code instead of parsing the response for the code.
    def handle_answer_mfa_response(response)
      if response['error_code'] == '0'
        # correct answer
        @mfa_verified = true
        AchUsNode.multiple_from_response(user, response['nodes'])
      elsif response['error_code'] == '10'
        # wrong answer or new additional MFA question
        @mfa_access_token = response['mfa']['access_token']
        @mfa_message      = response['mfa']['message']
        self
      end
    end
  end
end
