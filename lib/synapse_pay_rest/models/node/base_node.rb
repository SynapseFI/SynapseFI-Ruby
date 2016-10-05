module SynapsePayRest
  # ancestor of all nodes
  class BaseNode
    attr_reader :user, :id, :nickname, :supp_id, :currency, :is_active, :permissions,
                :account_number, :routing_number, :name_on_account, :address,
                :bank_name, :bank_id, :bank_pw, :account_class, :account_type,
                :correspondent_routing_number, :correspondent_bank_name,
                :correspondent_address, :correspondent_swift, :account_id, :balance,
                :ifsc, :swift, :bank_long_name, :type, :gateway_restricted

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
      def all(user:, page: nil, per_page: nil, type: nil)
        user.authenticate
        response = user.client.nodes.get(page: page, per_page: per_page, type: type)
        create_multiple_from_response(user, response['nodes'])
      end

      def by_type(user:, type:, page: nil, per_page: nil)
        all(user: user, type: type, page: page, per_page: per_page,)
      end

      def create_from_response(user, response)
        args = {
          user:            user,
          type:            response['type'],
          id:              response['_id'],
          is_active:       response['is_active'],
          permissions:     response['allowed'],
          nickname:        response['info']['nickname'],
          name_on_account: response['info']['name_on_account'],
          bank_long_name:  response['info']['bank_long_name'],
          bank_name:       response['info']['bank_name'],
          account_type:    response['info']['type'],
          account_class:   response['info']['class'],
          account_number:  response['info']['account_num'],
          routing_number:  response['info']['routing_num'],
          account_id:      response['info']['account_id'],
          address:         response['info']['address'],
          swift:           response['info']['swift'],
          ifsc:            response['info']['ifsc']
        }

        if response['info']['correspondent_info']
          args[:correspondent_swift]          = response['info']['correspondent_info']['swift']
          args[:correspondent_bank_name]      = response['info']['correspondent_info']['bank_name']
          args[:correspondent_routing_number] = response['info']['correspondent_info']['routing_num']
          args[:correspondent_address]        = response['info']['correspondent_info']['address']
          args[:correspondent_swift]          = response['info']['correspondent_info']['swift']
        end

        if response['info']['balance']
          args[:balance]  = response['info']['balance']['amount']
          args[:currency] = response['info']['balance']['currency']
        end

        if response['extra']
          args[:supp_id]            = response['extra']['supp_id']
          args[:gateway_restricted] = response['extra']['gateway_restricted']
        end

        self.new(**args)
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
