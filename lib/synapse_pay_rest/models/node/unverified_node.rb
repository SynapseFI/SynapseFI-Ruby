module SynapsePayRest
  class UnverifiedNode
    attr_reader :user, :mfa_access_token, :mfa_message, :mfa_verified

    def initialize(user:, mfa_access_token:, mfa_message:, mfa_verified:)
      @user             = user
      @mfa_access_token = mfa_access_token
      @mfa_message      = mfa_message
      @mfa_verified     = mfa_verified
    end

    def answer_mfa(answer:)
      payload = payload_for_answer_mfa(answer: answer)
      response = user.client.nodes.post(payload: payload)

      if response['error_code'] == 0
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
