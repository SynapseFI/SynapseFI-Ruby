module SynapsePayRest
  class Question
    attr_reader :question, :answers, :id, :choice

    def initialize(id:, question:, answers:)
      @id       = id
      @question = question
      @answers  = answers
      @choice   = nil
    end

    # TODO: raise error if choice not in answers
    # TODO: validate is integer (or string int)
    def choice=(answer_number)
      @choice = answer_number
    end

    def to_hash
      {'question_id' => id, 'answer_id' => choice}
    end
  end
end
