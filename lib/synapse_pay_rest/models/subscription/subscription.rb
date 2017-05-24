module SynapsePayRest
  # Represents a subscription record and holds methods for creating subsription instances
  # from API calls. This is built on top of the SynapsePayRest::Subscription class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode.
  class Subscription
    attr_reader :id, :is_active, :scope, :url

    class << self
      # Creates a new subscription in the API and returns a Subscription instance from the
      # response data.
      # 
      # @param client [SynapsePayRest::Client]
      # @param scope [Array<String>]
      # @param url [String]
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [SynapsePayRest::Subscription]
      def create(client:, url:, scope:, **options)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        
        payload = payload_for_create(url: url, scope: scope, **options)
        response = client.subscriptions.create(payload: payload)
        from_response(response)
      end

      # Creates a Subscription from a response hash.
      # 
      # @note Shouldn't need to call this directly.
      def from_response(response)
        args = {
          id:            response['_id'],
          is_active:     response['is_active'],
          scope:         response['scope'],
          url:           response['url']
        }
        self.new(args)
      end

      private

      # Converts #create args into API payload structure.
      def payload_for_create(**options)
        payload = {}
        # must have one of these
        payload['url']       = options[:url] if options[:url]
        payload['scope']     = options[:scope] if options[:scope]
        payload
      end

      # Converts #update args into API payload structure.
      def payload_for_update(**options)
        payload = {}
        # must have one of these
        payload['is_active'] = options[:is_active] if options[:is_active]
        payload['url']       = options[:url] if options[:url]
        payload['scope']     = options[:scope] if options[:scope]
        payload
      end

    end

    # @note Do not call directly. Use Subscription.create or other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    # Checks if two Subscription instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end
  end
end
