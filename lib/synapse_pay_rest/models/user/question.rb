module SynapsePayRest
  class Question
    attr_reader :question, :answers, :id, :choice

    def initialize(id:, question:, answers:)
      @id       = id
      @question = question
      @answers  = answers
      @choice   = nil
    end

    def choice=(answer_number)
      raise ArgumentError, 'must be an Integer' unless answer_number.is_a?(Integer)
      unless answers.keys.include? answer_number
        raise ArgumentError, "answer given must be in #{answers.keys}"
      end

      @choice = answer_number
    end

    def to_hash
      {'question_id' => id, 'answer_id' => choice}
    end
  end
end
