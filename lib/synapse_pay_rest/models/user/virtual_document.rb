module SynapsePayRest
  # Represents virtual documents that can be added to a base document.
  #
  # @see https://docs.synapsepay.com/docs/user-resources#section-virtual-document-types
  #   virtual document types
  class VirtualDocument < Document
    # @!attribute [r] question_set
    # @return [SynapsePayRest::Array<SynapsePayRest::Question>] questions/answer choices returned when document status is MFA|PENDING
    attr_reader :question_set

    def initialize(**options)
      super(**options)
      @question_set ||= []
    end

    # Submits the question/answer selections to the API to attempt to verify
    # the virtual document.
    #
    # @return [SynapsePayRest::VirtualDocument] (self)
    #
    # @todo should raise error if any questions aren't answered yet.
    def submit_kba
      user     = base_document.user
      response = user.client.users.update(payload: payload_for_kba)

      base_document_info = response['documents'].find { |d| d['id'] == base_document.id }
      ssn_docs = base_document_info['virtual_docs'].select { |doc_info| doc_info['document_type'] == 'SSN' }
      ssn_doc_info = ssn_docs.max_by { |doc_info| doc_info['last_updated'] }
      update_from_response(ssn_doc_info)

      self
    end

    # Modifies parent behavior to handle question_sets.
    # @note You shouldn't need to call this directly.
    def update_from_response(data)
      super(data)
      # handle mfa questions
      add_question_set(data['meta']['question_set']) if data['meta']
      self
    end

    private

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
