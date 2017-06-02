module SynapsePayRest
  # Ancestor of all node types. Should never be instantiated.
  # Represents a Node record and holds methods for constructing Node instances
  # from API calls. This is built on top of the SynapsePayRest::Nodes class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode. May be 
  #   better to refactor this into a mixin altogether since this shouldn't be instantiated. 
  # @todo reduce duplicated logic between User/BaseNode/Transaction
  class BaseNode

    # @!attribute [rw] user
    #   @return [SynapsePayRest::User] the user to which the node belongs
    # @!attribute [r] permission
    #   @return [String] https://docs.synapsepay.com/docs/node-resources#section-node-permissions
    attr_reader :user, :id, :nickname, :supp_id, :currency, :is_active, :permission,
                :account_number, :routing_number, :name_on_account, :address,
                :bank_name, :bank_id, :bank_pw, :account_class, :account_type,
                :correspondent_routing_number, :correspondent_bank_name,
                :correspondent_address, :correspondent_swift, :account_id, :balance,
                :ifsc, :swift, :bank_long_name, :type, :gateway_restricted,
                :email_match, :name_match, :phonenumber_match

    class << self
      # Creates a new node in the API associated to the provided user and
      # returns a node instance from the response data. See subclasses for type-specific
      # arguments.
      # 
      # @param user [SynapsePayRest::User] user to whom the node belongs
      # @param nickname [String]
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [SynapsePayRest::BaseNode]
      def create(user:, nickname:, **options)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        raise ArgumentError, 'nickname must be a String' unless nickname.is_a?(String)

        payload = payload_for_create(nickname: nickname, **options)
        response = user.client.nodes.add(user_id: user.id, payload: payload)
        from_response(user, response['nodes'].first)
      end

      # Queries the API for all nodes belonging to the supplied user (with optional
      # filters) and matching the given type of this node.
      # 
      # @param user [SynapsePayRest::User]
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [Array<SynapsePayRest::BaseNode>] BaseNode will be whatever subclass the method was called on
      def all(user:, page: nil, per_page: nil)
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end
        unless type.nil? || NODE_TYPES_TO_CLASSES.keys.include(type)
          raise ArgumentError, "type must be nil or in #{NODE_TYPES_TO_CLASSES.keys}"
        end
        
        response = user.client.nodes.get(
          user_id: user.id,
          page: page,
          per_page: per_page,
          type: self.type
        )
        multiple_from_response(user, response['nodes'])
      end

      # @note Not meant to be accessed directly on BaseNode but through children.
      def from_response(user, response)
        args = {
          user:                 user,
          type:                 response['type'],
          id:                   response['_id'],
          is_active:            response['is_active'],
          permission:           response['allowed'],
          nickname:             response['info']['nickname'],
          name_on_account:      response['info']['name_on_account'],
          bank_long_name:       response['info']['bank_long_name'],
          bank_name:            response['info']['bank_name'],
          account_type:         response['info']['type'],
          account_class:        response['info']['class'],
          account_number:       response['info']['account_num'],
          routing_number:       response['info']['routing_num'],
          address:              response['info']['address'],
          swift:                response['info']['swift'],
          ifsc:                 response['info']['ifsc'],
          user_info:            nil,
          transactions:         nil,
          timeline:             nil,
          billpay_info:         nil,
          transaction_analysis: nil
        }

        if response['info']['correspondent_info']
          correspondent_info = response['info']['correspondent_info']
          args[:correspondent_swift]          = correspondent_info['swift']
          args[:correspondent_bank_name]      = correspondent_info['bank_name']
          args[:correspondent_routing_number] = correspondent_info['routing_num']
          args[:correspondent_address]        = correspondent_info['address']
        end

        if response['info']['match_info']
          match_info = response['info']['match_info']
          args[:email_match]       = match_info['email_match']
          args[:name_match]        = match_info['name_match']
          args[:phonenumber_match] = match_info['phonenumber_match']
        end

        if response['info']['balance']
          balance = response['info']['balance']
          args[:balance]  = balance['amount']
          args[:currency] = balance['currency']
        end

        if response['extra']
          extra = response['extra']
          args[:supp_id]            = extra['supp_id']
          args[:gateway_restricted] = extra['gateway_restricted']
        end

        if response['extra']['other']
          user_info = response['extra']['other']['info']
          args[:user_info] = user_info

          transactions = response['extra']['other']['transactions']
          args[:transactions] = transactions

          billpay_info = response['extra']['other']['billpay_info']
          args[:billpay_info] = billpay_info

          transaction_analysis = response['extra']['other']['transaction_analysis']
          args[:transaction_analysis] = transaction_analysis
        end

        if response['timeline']
          timeline = response['timeline']
          args[:timeline] = timeline
        end

        self.new(**args)
      end

      # @note Not meant to be accessed directly on BaseNode but through children.
      def multiple_from_response(user, response)
        response.map { |node_data| from_response(user, node_data)}
      end

      def payload_for_create(type:, **options)
        payload = {
            'type' => type,
            'info' => {}
        }

        info_fields = [
          :swift, :name_on_account, :bank_name, :address, :ifsc,:nickname,
          :bank_name
        ]
        info_fields.each do |field|
          payload['info'][field.to_s] = options[field] if options[field]
        end

        # the rest are done individually since they are custom renamed
        correspondent_info = {}
        if options[:correspondent_routing_number]
          correspondent_info['routing_num'] = options[:correspondent_routing_number]
        end
        if options[:correspondent_bank_name]
          correspondent_info['bank_name'] = options[:correspondent_bank_name]
        end
        if options[:correspondent_address]
          correspondent_info['address'] = options[:correspondent_address]
        end
        if options[:correspondent_swift]
          correspondent_info['swift'] = options[:correspondent_swift]
        end
        payload['info']['correspondent_info'] = correspondent_info if correspondent_info.any?

        if options[:account_number]
          payload['info']['account_num'] = options[:account_number]
        end
        if options[:routing_number]
          payload['info']['routing_num'] = options[:routing_number]
        end
        if options[:account_type]
          payload['info']['type'] = options[:account_type]
        end
        if options[:account_class]
          payload['info']['class'] = options[:account_class]
        end
        if options[:username]
          payload['info']['bank_id'] = options[:username]
        end
        if options[:password]
          payload['info']['bank_pw'] = options[:password]
        end

        balance_fields = [:currency]
        balance_fields.each do |field|
          if options[field]
            payload['info']['balance'] ||= {}
            payload['info']['balance'][field.to_s] = options[field] if options[field]
          end
        end

        extra_fields = [:supp_id, :gateway_restricted]
        extra_fields.each do |field|
          if options[field]
            payload['extra'] ||= {}
            payload['extra'][field.to_s] = options[field] 
          end
        end

        payload
      end
    end

    # @note Do not call directly. Use <BaseNode subclass>.create or other
    #   class method to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    # Creates a transaction belonging to this node and returns it as a Transaction
    # instance.
    # 
    # @param to_id [String] node id of the receiving node
    # @param to_type [String] node type of the receiving node
    # @see https://docs.synapsepay.com/docs/node-resources valid node types
    # @param amount [Float] 100.0 = $100.00 for example
    # @param currency [String] e.g. 'USD'
    # @param ip [String]
    # @param note [String] (optional)
    # @param process_in [Integer] (optional) days until processed (default/minimum 1)
    # @param fee_amount [Float] (optional) fee amount to add to the transaction
    # @param fee_note [String] (optional)
    # @param fee_to_id [String] (optional) node id to which to send the fee
    # @param supp_id [String] (optional)
    # @param idempotency_key [String] (optional) avoid accidentally performing the same operation twice
    #
    # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
    # 
    # @return [SynapsePayRest::Transaction]
    def create_transaction(**options)
      Transaction.create(node: self, **options)
    end

    # Queries the API for all transactions belonging to this node and returns
    # them as Transaction instances.
    # 
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::Transaction>]
    def transactions(**options)
      Transaction.all(node: self, **options)
    end

    # Queries the API for a transaction belonging to this node by transaction id
    # and returns a Transaction instance if found.
    # 
    # @param id [String] id of the transaction to find
    # 
    # @raise [SynapsePayRest::Error] if not found or other HTTP error
    # 
    # @return [SynapsePayRest::Transaction]
    def find_transaction(id:)
      raise ArgumentError, 'id must be a String' unless id.is_a?(String)

      Transaction.find(node: self, id: id)
    end

    # Deactivates the node. 
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [:success]
    def deactivate
      response = user.client.nodes.delete(user_id: user.id, node_id: id)
      if response['_id']
        # api v3.1.1
        self.class.from_response(user, response)
      else
        # api v3.1
        nil
      end
    end

    # Checks if two BaseNode instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end
  end
end
