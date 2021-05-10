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
      path = shipment_resource_path(user_id: user_id,
                                    node_id: node_id,
                                    subnet_id: subnet_id,
                                    id: id)
      client.get(path)
    end

    private

    def shipment_resource_path(user_id:, node_id:, subnet_id:, id:)
      "/users/#{user_id}/nodes/#{node_id}/subnets/#{subnet_id}/ship/#{id}"
    end
  end
end
