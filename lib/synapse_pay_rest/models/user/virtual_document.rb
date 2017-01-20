module SynapsePayRest
  # Represents virtual documents that can be added to a base document.
  #
  # @see https://docs.synapsepay.com/docs/user-resources#section-virtual-document-types
  #   virtual document types
  class VirtualDocument < Document
    # @!attribute [r] question_set
    # @return [SynapsePayRest::Array<SynapsePayRest::Question>] questions/answer choices returned when document status is MFA|PENDING
    attr_reader :question_set

    class << self
      # @note Do not call this method directly.
      def from_response(data)
        virtual_doc = super(data)
        virtual_doc.add_question_set(data['meta']['question_set']) if data['status'] == 'SUBMITTED|MFA_PENDING'
        virtual_doc
      end
    end

    # @note It should not be necessary to call this method directly.
    def initialize(**options)
      super(**options)
    end

    # Submits the question/answer selections to the API to attempt to verify
    # the virtual document.
    #
    # @return [SynapsePayRest::VirtualDocument] (self)
    #
    # @deprecated
    def submit_kba
      user = base_document.user
      response = user.client.users.update(user_id: user.id, payload: payload_for_kba)
      user     = User.from_response(user.client, response)
      base_doc = user.base_documents.find { |doc| doc.id == base_document.id }
      ssn_doc  = base_doc.virtual_documents.find { |doc| doc.id == id }
    end

    # Maps question set from response to Question objects.
    # 
    # @deprecated
    def add_question_set(question_set_data)
      questions = question_set_data['questions'].map do |question_info|
        # re-map question/answer hash structure
        answers = {}
        question_info['answers'].each do |answer_hash|
          answers[answer_hash['id']] = answer_hash['answer']
        end

        Question.new(
          id:       question_info['id'],
          question: question_info['question'],
          answers:  answers
        )
      end

      @question_set = questions
    end

    private

    # @deprecated
    def payload_for_kba
      {
        'documents' => [{
          'id' => base_document.id,
          'virtual_docs' => [{
            'id' => id,
            'meta' => {
              'question_set' => {
                'answers' => question_set.map(&:to_hash)
              }
            }
          }]
        }]
      }
    end
  end
end
