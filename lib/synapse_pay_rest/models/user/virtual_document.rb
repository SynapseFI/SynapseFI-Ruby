module SynapsePayRest
  class VirtualDocument < Document
    attr_reader :question_set

    def initialize(**options)
      super(options)
      @question_set ||= []
    end

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

    def submit_kba
      user = kyc.user
      response = user.client.users.update(payload: payload_for_kba)

      kyc_info = response['documents'].find { |d| d['id'] == kyc.id }
      ssn_docs = kyc_info['virtual_docs'].select { |doc_info| doc_info['document_type'] == 'SSN' }
      ssn_doc_info = ssn_docs.max_by { |doc_info| doc_info['last_updated'] }
      update_from_response_fields(ssn_doc_info)

      self
    end

    def update_from_response_fields(data)
      super(data)
      # handle mfa questions
      add_question_set(data['meta']['question_set']) if data['meta']
      self
    end

    private

    def payload_for_kba
      {
        'documents' => [{
          'id' => kyc.id,
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
