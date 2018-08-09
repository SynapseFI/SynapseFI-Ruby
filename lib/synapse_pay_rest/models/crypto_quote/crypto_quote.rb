module SynapsePayRest
  # Represents a public key record and holds methods for getting crypto quote
  # from API calls. This is built on top of the SynapsePayRest::Client class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  class CryptoQuote
    attr_reader :client, :btcusd, :ethusd, :usdbtc, :usdeth

    class << self

      # Creates a crypto quote from a response hash.
      # 
      # @note Shouldn't need to call this directly.
      def from_response(client, response)
        args = {
          client:                    client,
          btcusd:        response['BTCUSD'],
          ethusd:        response['ETHUSD'],
          usdbtc:        response['USDBTC'],
          usdeth:        response['USDETH']
        }
        self.new(args)
      end

      def get(client:)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        response = client.crypto_quotes.get()
        self.from_response(client, response)
      end

    end

    # @note Do not call directly. Use other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

  end
end