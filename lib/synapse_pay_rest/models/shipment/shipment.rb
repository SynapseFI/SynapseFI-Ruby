module SynapsePayRest
  # Represents a Shipment record and holds methods for constructing Shipment instances
  # from API calls. This is built on top of the SynapsePayRest::Shipments class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  #
  class Shipment
    attr_reader :id, :address, :card_style_id, :created_on, :delivery,
                :delivery_carrier, :name, :secondary_label, :status,
                :subnet_id, :tracking

    # @note Do not call directly. Use Shipment.find or other class
    # method to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    class << self
      # Queries the API for a Shipment and returns a Subnet n instance if found.
      #
      # @param client [SynapsePayRest::Client]
      # @param user_id [String] id of the user to which the Shipment belongs
      # @param node_id [String] id of the node to which the Shipment belongs
      # @param subnet_id [String] id of the subnet to which the Shipment belongs
      # @param id [String] id of the Shipment
      #
      # @raise [SynapsePayRest::Error] if not found or other HTTP error
      #
      # @return [SynapsePayRest::Subnet]
      def find(client:, user_id:, node_id:, subnet_id:, id:)
        response = client.shipments.get(user_id: user_id,
                                        node_id: node_id,
                                        subnet_id: subnet_id,
                                        id: id)
        self.new(
          id: response["_id"],
          address: response["address"],
          card_style_id: response["card_style_id"],
          created_on: response["created_on"],
          delivery: response["delivery"],
          delivery_carrier: response["delivery_carrier"],
          name: response["name"],
          secondary_label: response["secondary_label"],
          status: response["status"],
          subnet_id: response["subnet_id"],
          tracking: response["tracking"],
        )
      end
    end
  end
end
