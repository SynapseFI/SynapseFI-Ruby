module SynapsePayRest
  # Represents a question that is triggered when a document is returned with
  # status MFA|PENDING.
  # 
  # @deprecated
  class Question
    # @!attribute [r] question
    #   @return [String] the text of the question
    # @!attribute [r] answers
    #   @return [Hash{Integer=>String}] the answer choice numbers and text
    # @!attribute [r] id
    #   @return [Integer] the number of the question in the question_set
    # @!attribute [r] choice
    #   @return [String,void] the chosen answer (starts out nil)
    attr_reader :question, :answers, :id, :choice

    # @note This is initialized automatically by SynapsePayRest::VirtualDocument.
    def initialize(id:, question:, answers:)
      @id       = id
      @question = question
      @answers  = answers
      @choice   = nil
    end

    # Selects the user's answer choice for this question. This does not submit
    # it to the API - you must call VirtualDocument#submit once all questions
    # have been answered.
    # 
    # @param answer_number [Integer] the user's chosen answer
    # 
    # @return [Integer] the answer chosen
    def choice=(answer_number)
      raise ArgumentError, 'answer_number must be an Integer' unless answer_number.is_a?(Integer)
      unless answers.keys.include? answer_number
        raise ArgumentError, "answer given must be in #{answers.keys}"
      end

      @choice = answer_number
    end

    # Converts the question/answer to a hash for use in JSON.
    # @note You should not need to call this directly.
    def to_hash
      {'question_id' => id, 'answer_id' => choice}
    end
  end
end
