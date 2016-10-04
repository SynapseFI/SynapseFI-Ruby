module SynapsePayRest
  # ancestor of all nodes
  class BaseNode
    attr_reader :user, :id, :nickname, :supp_id, :currency, :is_active, :permissions,
                :account_number, :routing_number, :name_on_account, :address,
                :bank_name, :bank_id, :bank_pw, :account_class, :account_type,
                :correspondent_routing_number, :correspondent_bank_name,
                :correspondent_address, :correspondent_swift, :account_id, :balance,
                :ifsc, :swift, :bank_long_name, :balance, :type

    class << self
      def create(user:, nickname:, **options)
        payload = payload_for_create(nickname: nickname, **options)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        create_from_response(user, response['nodes'].first)
      end

      def find(user:, id:)
        user.authenticate
        response = user.client.nodes.get(user_id: user.id, node_id: id)
        subclass_from_response(user, response)
      end

      # TODO: validate arguments in valid range / type options
      def all(user:, page: 1, per_page: 20, type: nil)
        user.authenticate
        response = user.client.nodes.get(page: page, per_page: per_page, type: type)
        create_multiple_from_response(user, response['nodes'])
      end

      def by_type(user:, type:, page: 1, per_page: 20)
        all(user: user, page: page, per_page: per_page, type: type)
      end

      # TODO: this is implemented differently in each subclass. can prob 
      # benefit from inheritance
      def create_from_response(user, response)
        # TODO: create UnknownNodeType or something if somehow called on BaseNode
      end

      def create_multiple_from_response(user, response)
        response.map { |node_data| create_from_response(user, node_data)}
      end
    end

    # TODO: prevent initializing directly?
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def transactions(**options)
      Transaction.all(node: self, **options)
    end

    def find_transaction(id:)
      Transaction.find(node: self, id: id)
    end

    def destroy
      user.authenticate
      user.client.nodes.delete(node_id: id)
      nil
    end

    def ==(other)
      other.instance_of?(self.class) && !id.nil? &&  id == other.id 
    end
  end
end
