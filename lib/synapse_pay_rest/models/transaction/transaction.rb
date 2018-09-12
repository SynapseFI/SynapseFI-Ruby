module SynapsePayRest
  # Represents a transaction record and holds methods for constructing transaction instances
  # from API calls. This is built on top of the SynapsePayRest::Transactions class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode.
  # @todo reduce duplicated logic between User/BaseNode/Transaction
  class Transaction
    # @!attribute [rw] node
    #   @return [SynapsePayRest::Node] the node to which the transaction belongs
    attr_reader :node, :id, :amount, :currency, :client_id, :client_name, :created_on,
                :ip, :latlon, :note, :process_on, :supp_id, :webhook, :fees,
                :recent_status, :timeline, :from, :to, :to_type, :to_id,
                :fee_amount, :fee_note, :fee_to_id , :asset, :same_day

    class << self
      # Creates a new transaction in the API belonging to the provided node and
      # returns a transaction instance from the response data.
      # 
      # @param node [SynapsePayRest::BaseNode] node to which the transaction belongs
      # @param to_id [String] node id of the receiving node
      # @param to_type [String] node type of the receiving node
      # @see https://docs.synapsepay.com/docs/node-resources valid node types
      # @param amount [Float] 100.0 = $100.00 for example
      # @param currency [String] e.g. 'USD'
      # @param ip [String]
      # @param note [String] (optional)
      # @param process_in [Integer] (optional) days until processed (default/minimum 1)
      # @param fees [Array] (optional) fee amounts to add to the transaction. Example: [{fee: 1.0, note: 'Test Fee', to: {id: 'fee_node_id'}}]
      # @param fee_amount [Float] (deprecated) fee amount to add to the transaction
      # @param fee_to_id [String] (deprecated) node id to which to send the fee (must be SYNAPSE-US)
      # @param fee_note [String] (deprecated)
      # @param supp_id [String] (optional)
      # @param idempotency_key [String] (optional)
      #
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [SynapsePayRest::Transaction]
      # 
      # @todo allow either to_node or to_type/to_id
      # @todo allow node to be entered as alternative to fee_to node
      # @todo validate if fee_to node is synapse-us
      # @todo allow multiple fees
      def create(node:, to_type:, to_id:, amount:, currency:, ip:, **options)
        raise ArgumentError, 'cannot create a transaction with an UnverifiedNode' if node.is_a?(UnverifiedNode)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        raise ArgumentError, 'amount must be a Numeric (Integer or Float)' unless amount.is_a?(Numeric)
        [to_type, to_id, currency, ip].each do |arg|
          if options[arg] && !options[arg].is_a?(String)
            raise ArgumentError, "#{arg} must be a String"
          end
        end

        payload = payload_for_create(node: node, to_type: to_type, to_id: to_id,
          amount: amount, currency: currency, ip: ip, **options)
        response = node.user.client.trans.create(
          user_id: node.user.id,
          node_id: node.id,
          payload: payload,
          idempotency_key: options[:idempotency_key],
        )
        from_response(node, response)
      end

      # Queries the API for a transaction belonging to the supplied node by transaction id
      # and returns a Transaction instance if found.
      # 
      # @param node [SynapsePayRest::BaseNode] node to which the transaction belongs
      # @param id [String] id of the transaction to find
      # 
      # @raise [SynapsePayRest::Error] if not found or other HTTP error
      # 
      # @return [SynapsePayRest::Transaction]
      def find(node:, id:)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        response = node.user.client.trans.get(
          user_id: node.user.id,
          node_id: node.id,
          trans_id: id
        )
        from_response(node, response)
      end

      # Queries the API for all transactions belonging to the supplied node and returns
      # them as Transaction instances.
      # 
      # @param node [SynapsePayRest::BaseNode] node to which the transaction belongs
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [Array<SynapsePayRest::Transaction>]
      def all(node:, page: nil, per_page: nil)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end

        response = node.user.client.trans.get(
          user_id: node.user.id,
          node_id: node.id,
          page: page,
          per_page: per_page
        )
        multiple_from_response(node, response['trans'])
      end

      # Creates a Transaction from a response hash.
      # 
      # @note Shouldn't need to call this directly.
      # 
      # @todo convert the nodes and users in response into User/Node objects
      # @todo rework to handle multiple fees
      def from_response(node, response)
        args = {
          node:          node,
          id:            response['_id'],
          amount:        response['amount']['amount'],
          currency:      response['amount']['currency'],
          client_id:     response['client']['id'],
          client_name:   response['client']['name'],
          created_on:    response['extra']['created_on'],
          ip:            response['extra']['ip'],
          latlon:        response['extra']['latlon'],
          note:          response['extra']['note'],
          process_on:    response['extra']['process_on'],
          same_day:      response['extra']['same_day'],
          supp_id:       response['extra']['supp_id'],
          webhook:       response['extra']['webhook'],
          fees:          response['fees'],
          recent_status: response['recent_status'],
          timeline:      response['timeline'],
          from:          response['from'],
          to:            response['to'],
          to_type:       response['to']['type'],
          to_id:         response['to']['id']
        }
        if response['fees'].any?
          args[:fee_amount] = response['fees'].first['fee']
          args[:fee_note]   = response['fees'].first['note']
          args[:fee_to_id]  = response['fees'].first['to']['id']
        end
        self.new(args)
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
        payload['extra']['asset']      = options[:asset] if options[:asset]
        payload['extra']['same_day']   = options[:same_day] if options[:same_day]
        payload['extra']['supp_id']    = options[:supp_id] if options[:supp_id]
        payload['extra']['note']       = options[:note] if options[:note]
        payload['extra']['process_on'] = options[:process_in] if options[:process_in]
        other = {}
        other['attachments'] = options[:attachments] if options[:attachments]
        payload['extra']['other'] = other if other.any?
        fees = []
        # deprecated fee flow
        fee = {}
        fee['fee']  = options[:fee_amount] if options[:fee_amount]
        fee['note'] = options[:fee_note] if options[:fee_note]
        fee_to = {}
        fee_to['id'] = options[:fee_to_id] if options[:fee_to_id]
        fee['to'] = fee_to if fee_to.any?
        fees << fee if fee.any?
        # new fee flow
        fees = options[:fees] if options[:fees]
        payload['fees'] = fees if fees.any?
        payload
      end

      def multiple_from_response(node, response)
        return [] if response.empty?
        response.map { |trans_data| from_response(node, trans_data) }
      end
    end

    # @note Do not call directly. Use Transaction.create or other class
    #   method to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    # Adds a comment to the transaction's timeline/recent_status fields.
    # 
    # @param comment [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::Transaction>] (self)
    def add_comment(comment)
      payload = {'comment' => comment}
      response = node.user.client.trans.update(
        user_id: node.user.id,
        node_id: node.id,
        trans_id: id,
        payload: payload
      )
      if response['trans']
        # api v3.1
        self.class.from_response(node, response['trans'])
      else
        # api v3.1.1
        self.class.from_response(node, response)
      end
    end

    # Cancels this transaction if it has not already settled.
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::Transaction>] (self)
    def cancel
      response = node.user.client.trans.delete(
        user_id: node.user.id,
        node_id: node.id,
        trans_id: id
      )
      self.class.from_response(node, response)
    end

    # Checks if two Transaction instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end
  end
end
