module SynapsePayRest
  # Represents an institution record and holds methods for getting institution instances
  # from API calls. This is built on top of the SynapsePayRest::Institution class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode.
  class Institution
    attr_reader :id, :is_active, :scope, :url

    class << self
      def all(client:)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        response = client.institutions.get()
        multiple_from_response(response['banks'])
      end

      # Creates an Institution from a response hash.
      # 
      # @note Shouldn't need to call this directly.
      def from_response(response)
        args = {
          bank_code:                    response['bank_code'],
          bank_name:                    response['bank_name'],
          features:                     response['features'],
          forgotten_password:           response['forgotten_password'],
          is_active:                    response['is_active'],
          logo:                         response['logo'],
          tx_history_months:            response['tx_history_months']
        }
        self.new(args)
      end

      # Calls from_response on each member of a response collection.
      def multiple_from_response(response)
        return [] if response.empty?
        response.map { |institution_data| from_response(institution_data)}
      end

      private

    end
  end
end
