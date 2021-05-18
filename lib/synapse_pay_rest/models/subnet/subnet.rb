module SynapsePayRest
  # Represents a subnet record and holds methods for constructing subnet instances
  # from API calls. This is built on top of the SynapsePayRest::Subnets class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  class Subnet
    # @!attribute [rw] node
    attr_reader :id, :account_num, :account_class, :allowed, :client_id, :client_name, :nickname, :node,
                :routing_num_ach, :routing_num_wire, :status, :account_class, :card_hash, :card_number,
                :cvc, :exp, :card_style_id
    class << self
      # Creates a new subnet in the API belonging to the provided node and
      # returns a subnet instance from the response data.
      # 
      # @param nickname [String] any nicknames
      # @param node [SynapsePayRest::BaseNode] node to which the Subnet belongs
      # @see https://docs.synapsepay.com/docs/subnets
      #
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [SynapsePayRest::Subnet]
      # 
      def create(node:, nickname:, **options)
        raise ArgumentError, 'cannot create a transaction with an UnverifiedNode' if node.is_a?(UnverifiedNode)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        [nickname].each do |arg|
          if options[arg] && !options[arg].is_a?(String)
            raise ArgumentError, "#{arg} must be a String"
          end
        end

        payload = payload_for_create(node: node, nickname: nickname, **options)
        response = node.user.client.subnets.create(
          user_id: node.user.id,
          node_id: node.id,
          payload: payload,
        )
        from_response(node, response)
      end

      # Queries the API for a subnet belonging to the supplied node by subnet id
      # and returns a Subnet n instance if found.
      # 
      # @param node [SynapsePayRest::BaseNode] node to which the subnet belongs
      # @param id [String] id of the subnet to find
      # 
      # @raise [SynapsePayRest::Error] if not found or other HTTP error
      # 
      # @return [SynapsePayRest::Subnet]
      def find(node:, id:, full_dehydrate: false)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        response = node.user.client.subnets.get(
          user_id: node.user.id,
          node_id: node.id,
          subnet_id: id,
          full_dehydrate: full_dehydrate
        )
        from_response(node, response)
      end

      # Queries the API for all subnets belonging to the supplied node and returns
      # them as Subnet instances.
      # 
      # @param node [SynapsePayRest::BaseNode] node to which the subnet belongs
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [Array<SynapsePayRest::Subnet>]
      def all(node:, page: nil, per_page: nil)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end

        response = node.user.client.subnets.get(
          user_id: node.user.id,
          node_id: node.id,
          page: page,
          per_page: per_page
        )
        multiple_from_response(node, response['subnets'])
      end

      # Creates a Subnet from a response hash.
      # 
      # @note Shouldn't need to call this directly.
      # 
      def from_response(node, response)
        args = {
          node:               node,
          id:                 response['_id'],
          account_class:      response['account_class'],
          allowed:            response['allowed'],
          client_id:          response['client']['id'],
          client_name:        response['client']['name'],
          nickname:           response['nickname'],
          node_id:            response['node_id'],
          status:             response['status'],
          user_id:            response['user_id']
        }
        additional_args = response['account_class'] == "CHECKING" ? args_for_checking_subnet(response) : args_for_card_subnet(response)
        self.new(args.merge(additional_args))
      end

      private

      def payload_for_create(node:, nickname:, **options)
        payload = {
          'nickname' => nickname
        }
        payload['account_class'] = options[:account_class] if options[:account_class].present?
        payload
      end

      def multiple_from_response(node, response)
        return [] if response.empty?
        response.map { |subnets_data| from_response(node, subnets_data) }
      end

      def args_for_checking_subnet(response)
        {
          account_num:        response['account_num'],
          routing_num_ach:    response['routing_num']['ach'],
          routing_num_wire:   response['routing_num']['wire']
        }
      end

      def args_for_card_subnet(response)
        {
          card_number:        response['card_number'],
          card_style_id:      response['card_style_id'],
          cvc:                response['cvc'],
          exp:                response['exp']
        }
      end
    end

    # @note Do not call directly. Use Subnet.create or other class
    #   method to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    # Changes Subnet's allowed permission from 'CREDIT' to 'LOCKED'.
    # 
    # @param comment [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::Subnet>] (self)
    def lock
      payload = {'allowed' => 'LOCKED'}
      response = node.user.client.subnets.update(
        user_id: node.user.id,
        node_id: node.id,
        subnet_id: id,
        payload: payload
      )
      if response['subnets']
        # api v3.1
        self.class.from_response(node, response['subnets'])
      else
        # api v3.1.1
        self.class.from_response(node, response)
      end
    end

    # TODO: remove once ENG-5682 is on Production
    # Ship a physical card
    #
    # @param fee_node_id [String] ID of the Node to be charged for printing/shipping costs
    # @param cardholder_name [String] Name of the cardholder
    # @param shipping_speed [String] Sets shipping speed of card
    # @param card_style_id [String] The numeric value representing the design style of the card
    # @param **options [Hash] Options to pass to Synapse's API
    #
    # @raise [SynapsePayRest::Error]
    #
    # @return [Hash] {
    #   node_id [String]
    #   subnet_id [String]
    #   transaction_id [String]
    # }
    def ship_card(fee_node_id, cardholder_name, shipping_speed, card_style_id, **options)
      payload = {
        fee_node_id: fee_node_id,
        cardholder_name: cardholder_name,
        delivery: shipping_speed,
        card_style_id: card_style_id,
      }

      payload["secondary_label"] = options["secondary_label"] if options["secondary_label"].present?

      response = node.user.client.subnets.ship(
        user_id: node.user.id,
        node_id: node.id,
        subnet_id: id,
        payload: payload,
      )

      if response["error"]
        args = {
          error: {
            code: response["error"]["code"],
            message: response["error"]["en"],
            error_code: response["error_code"],
            http_code: response["http_code"],
          },
        }
      else
        args = {
          transaction_id: response["transaction_id"],
          node_id: response["node_id"],
          subnet_id: response["subnet_id"],
        }
      end

      args
    end

    def get_card_shipment_info
      response = node.user.client.subnets.view_shipment_info(
          user_id: node.user.id,
          node_id: node.id,
          subnet_id: id
      )
      if response['error']
        args = {
            error: {
                code:           response['error']['code'],
                message:        response['error']['en'],
                error_code:     response['error_code'],
                http_code:      response['http_code']
            }
        }
      else
        args = response['ships']
      end
      
      args
    end
    # Updates the given key value pairs.
    # 
    # @param pin [String]
    # @param status [String]
    # @param preferences [Hash]:
    #   {
    #     allow_foreign_transactions [Boolean],
    #     daily_atm_withdrawal_limit [String, Integer],
    #     daily_transaction_limit [String, Integer]
    #   }
    # 
    # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
    # 
    # @return [SynapsePayRest::Subnet] new instance corresponding to same API record
    def update(**options)
      response = node.user.client.subnets.update(
        user_id: node.user.id,
        node_id: node.id,
        subnet_id: id,
        payload: payload_for_card_update(options)
      )
      # return an updated subnet instance
      self.class.from_response(node, response)
    end


    # Checks if two Subnet instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end

    private

    # Converts #update args into API payload structure for CARD subnets.
    def payload_for_card_update(**options)
      payload = {}
      # must have one of these
      payload['pin']     = options[:pin] if options[:pin]
      payload['status']  = options[:status] if options[:status]

      unless payload['pin'] || payload['status']
        raise ArgumentError, 'must provide a key-value pair to update. keys: pin,
          status, preferences[:allow_foreign_transactions],
          preferences[:daily_atm_withdrawal_limit], preferences[:daily_transaction_limit]'
      end

      if options[:preferences]
        payload['preferences'] = {}

        options[:preferences].each do |key ,value|
          payload['preferences'][key.to_s] = value
        end
      end

      payload
    end
  end
end
