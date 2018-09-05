module SynapsePayRest
  # Represents social documents that can be added to a base document.
  #
  # @see https://docs.synapsepay.com/docs/user-resources#section-social-document-types
  #   social document types
  class SocialDocument < Document

    # Verifies the pin sent via the user's social doc either EMAIL_2FA or PHONE_NUMBER_2FA
    # status is SUBMITTED|MFA_PENDING before verified
    # 
    # @param mfa_answer [String]
    # @param value [String]
    # 
    # @raise [SynapsePayRest::Error] if wrong guess or HTTP error
    # 
    # @return [SynapsePayRest::SocialDocument]
    def verify_2fa(mfa_answer:, value:)
      user = base_document.user
      payload = verify_social_doc_2fa_payload(mfa_answer: mfa_answer, type: type, value: value)
      response = user.client.users.update(user_id: user.id, payload: payload)
      user = User.from_response(user.client, response)
      social_doc = base_document.social_documents.find { |doc| doc.type == type }
    end

    private

    # Converts the data to hash format for request JSON.
    def verify_social_doc_2fa_payload(mfa_answer:, type:, value:)
      {
        'documents' => [{
          'id' => base_document.id,
          'social_docs' => [{
            'id' => id,
            'document_value' => value,
            'document_type' => type,
            'mfa_answer' => mfa_answer
          }]
        }]
      }
    end

  end
end
