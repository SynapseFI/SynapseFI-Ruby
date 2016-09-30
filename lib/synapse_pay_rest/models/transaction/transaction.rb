module SynapsePayRest
  class Transaction
    # TODO: (maybe) write == method to check if trans have same id

    class << self
      # TODO: validate args types
      def create(node:, to_type:, to_id:, amount:, currency:, ip:, **options)
        payload = payload_for_create(node: node, to_type: to_type, to_id: to_id,
          amount: amount, currency: currency, ip: ip, **options)
        node.user.authenticate
        response = node.user.client.nodes.create(node_id: node.id, payload: payload)
      end

      private

      def payload_for_create(node:, to_type:, to_id:, amount:, currency:, ip:,
        **options)
        payload = {
          'to' => {
            'type' => to_type,
            'id' => to_id
          },
          'amount' => {
            'amount' => amount,
            'currency' => currency
          },
          'extra' => {
            'ip' => ip
          }
        }
        # optional payload fields
        payload['extra']['supp_id']    = options[:supp_id] if options[:supp_id]
        payload['extra']['note']       = options[:note] if options[:note]
        payload['extra']['process_on'] = options[:process_on] if options[:process_on]
        other = {}
        other['attachments'] = options[:attachments] if options[:attachments]
        payload['other'] = other if other.any?
        fees = {}
        fees['fee']  = options[:fee_amount] if options[:fee_amount]
        fees['note'] = options[:fee_note] if options[:fee_note]
        fees_to = {}
        fees_to['id'] = options[:fee_to] if options[:fee_to]
        fees['to'] = fees_to if fees_to.any?
        payload['fees'] = fees if fees.any?

        payload
      end
    end

    def initialize(**options)
    end
  end
end
