module SynapsePayRest
  class UnverifiedNode
    attr_reader :user, :mfa_access_token, :mfa_message, :mfa_verified

    def initialize(user:, mfa_access_token:, mfa_message:, mfa_verified:)
      @user             = user
      @mfa_access_token = mfa_access_token
      @mfa_message      = mfa_message
      @mfa_verified     = mfa_verified
    end

    # TODO: raise error if already verified
    def answer_mfa(answer:)
      payload = payload_for_answer_mfa(answer: answer)
      response = user.client.nodes.post(payload: payload)

      if response['success']
        @mfa_verified = true
        AchUsNode.create_multiple_from_response(user, response['nodes'])
      else
        # TODO: raise error for wrong mfa answer / too many tries
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
