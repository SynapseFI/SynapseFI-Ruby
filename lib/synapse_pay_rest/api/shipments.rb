module SynapsePayRest
  # Wrapper class for /subnets endpoints
  #
  class Shipments
    # @!attribute [rw] client
    #   @return [SynapsePayRest::HTTPClient]
    attr_accessor :client

    # @param client [SynapsePayRest::HTTPClient]
    def initialize(client)
      @client = client
    end

    # Sends a GET request to /shipments endpoint. Queries a specific shipment.
    # Returns the response.
    #
    # @param user_id [String]
    # @param node_id [String]
    # @param subnet_id [String]
    # @param id [String]
    #
    # @raise [SynapsePayRest::Error] may return subclasses of error based on
    # HTTP response from API
    #
    # @return [Hash] API response
    #
    def get(user_id:, node_id:, subnet_id:, id:)
      path = shipments_resource_path(user_id: user_id,
                                     node_id: node_id,
                                     subnet_id: subnet_id,
                                     id: id)
      client.get(path)
    end

    # Sends a POST request to /shipments endpoint to create a new shipment.
    # Returns the response.
    #
    # @param user_id [String] user_id associated with the subnet
    # @param node_id [String] node the subnet belongs to
    # @param subnet_id [String] subnet to which the shipment belongs to
    # @param payload [Hash]
    # @see https://docs.synapsefi.com/api-references/shipments/shipment-object-details payload structure
    #
    # @raise [SynapsePayRest::Error] may return subclasses of error based on
    # HTTP response from API
    #
    # @return [Hash] API response
    def create(user_id:, node_id:, subnet_id:, payload:)
      path = shipments_resource_path(user_id: user_id,
                                     node_id: node_id,
                                     subnet_id: subnet_id)
      client.post(path, payload)
    end

    private

    def shipments_resource_path(user_id:, node_id:, subnet_id:, id: nil)
      path = "/users/#{user_id}/nodes/#{node_id}/subnets/#{subnet_id}/ship"
      path += "/#{id}" if id
      path
    end
  end
end
