module SynapsePayRest
  # Represents a subnet record and holds methods for constructing subnet instances
  # from API calls. This is built on top of the SynapsePayRest::Subnets class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  class Subnet
    # @!attribute [rw] node
    attr_reader :id, :account_num, :allowed, :client_id, :client_name, :nickname, :node, :routing_num_ach, 
                :routing_num_wire
                

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
      def find(node:, id:)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        response = node.user.client.subnets.get(
          user_id: node.user.id,
          node_id: node.id,
          subnet_id: id
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
          account_num:        response['account_num'],
          allowed:            response['allowed'],
          client_id:          response['client']['id'],
          client_name:        response['client']['name'],
          nickname:           response['nickname'],
          node_id:            response['node_id'],
          routing_num_ach:    response['routing_num']['ach'],
          routing_num_wire:   response['routing_num']['wire'],
          user_id:            response['user_id']
        }
        self.new(args)
      end

      private

      def payload_for_create(node:, nickname:, **options)
        payload = {
          'nickname' => nickname
        }
      end

      def multiple_from_response(node, response)
        return [] if response.empty?
        response.map { |subnets_data| from_response(node, subnets_data) }
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

    # Checks if two Subnet instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end
  end
end
