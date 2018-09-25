module SynapsePayRest
  # Represents a statement record and holds methods for getting statements
  # from API calls. This is built on top of the SynapsePayRest::Client class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  class Statement
    attr_reader :client, :id, :date_end, :date_start, :csv_url, :pdf_url, :json_url, :user, :node

    class << self
      # Creates a statements instance from a response hash.
      # @note Shouldn't need to call this directly.
      def from_response(client, response)
        args = {
          client:                   client,
          id:                       response['_id'],
          date_end:                 response['date_end'],
          date_start:               response['date_start'],
          csv_url:                  response['urls']['csv'],
          pdf_url:                  response['urls']['pdf'],
          json_url:                 response['urls']['json']
        }
        self.new(args)
      end

      # Gets statement by node or user.
      # @param client [SynapsePayRest::Client]
      # @param user [SynapsePayRest::User]  
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [SynapsePayRest::Statement] new instance corresponding to same API record
      def by_user(client:, user:, page: nil, per_page: nil)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        raise ArgumentError, 'id must be a SynapsePayRest::User' unless user.is_a?(User)

        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end

        response = client.statements.get(user_id: user.id, page: page, per_page: per_page)
        multiple_from_response(client, response['statements'])
      end

      # Gets statement by node or user.
      # @param client [SynapsePayRest::Client] 
      # @param user [SynapsePayRest::Node] 
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [SynapsePayRest::Statement] new instance corresponding to same API record
      def by_node(client:, node:, page: nil, per_page: nil)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        raise ArgumentError, 'node must be a SynapsePayRest::Node' unless node.is_a?(BaseNode)

        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end

        response = client.statements.get(user_id: node.user.id, node_id: node.id, page: page, per_page: per_page)
        multiple_from_response(client, response['statements'])
      end

      def multiple_from_response(client, response)
        return [] if response.empty?
        response.map { |statement_data| from_response(client, statement_data) }
      end

    end

    # @note Do not call directly. Use Statement.get or other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

  end
end