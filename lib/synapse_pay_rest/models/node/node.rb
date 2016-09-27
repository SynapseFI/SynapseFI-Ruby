module SynapsePayRest
  class Node
    attr_reader :user, :id, :nickname, :supp_id, :currency,
                :account_number, :routing_number, :name_on_account, :address,
                :bank_name, :bank_id, :bank_pw, :account_number, :routing_number,
                :type, :account_class, :account_type, :correspondent_routing_number,
                :correspondent_bank_name, :correspondent_address, :ifsc, :swift,
                :correspondent_swift, :account_id, :balance, :is_active, :allowed,
                :bank_long_name

    class << self
      def create(user:, nickname:, **options)
        payload = payload_for_create(nickname: nickname, **options)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        create_from_response(user, response)
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end
  end
end
