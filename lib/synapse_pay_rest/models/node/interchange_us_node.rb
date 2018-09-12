module SynapsePayRest

  class InterchangeUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, card_number:, exp_date:, document_id:, **options)
        args = {
          type: 'INTERCHANGE-US',
          nickname: nickname,
          card_number: card_number,
          exp_date: exp_date,
          document_id: document_id
        }.merge(options)
        super(args)
      end
    end
  end
end