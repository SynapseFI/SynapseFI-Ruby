module SynapsePayRest
  # Represents a public key record and holds methods for getting public key instances
  # from API calls. This is built on top of the SynapsePayRest::Client class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  class PublicKey 
    attr_reader :client, :client_obj_id, :expires_at, :expires_in, :public_key, :scope

    class << self
      # Creates a client public key from a response hash.
      # @note Shouldn't need to call this directly.
      def from_response(response)
        args = {
          client:                    response['client'],
          client_obj_id:             response['public_key_obj']['client_obj_id'],
          expires_at:                response['public_key_obj']['expires_at'],
          expires_in:                response['public_key_obj']['expires_in'],
          public_key:                response['public_key_obj']['public_key'],
          scope:                     response['public_key_obj']['scope']
        }
        self.new(args)
      end

      #Issues public key for client.
      # @param client [SynapsePayRest::Client]
      # @param scope [String]
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [SynapsePayRest::PublicKey] new instance corresponding to same API record
      def issue(client:, scope: "OAUTH|POST,USERS|POST,USERS|GET,USER|GET,USER|PATCH,SUBSCRIPTIONS|GET,SUBSCRIPTIONS|POST,SUBSCRIPTION|GET,SUBSCRIPTION|PATCH,CLIENT|REPORTS,CLIENT|CONTROLS")
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        raise ArgumentError, 'scope must be a String' unless scope.is_a?(String)

        response = client.client_endpoint.issue_public_key(scope: scope)
        from_response(response)
      end
    end

    # @note Do not call directly. Use PublicKey.issue or other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

  end
end