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
    def initialize(options)
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
        from_response(response)
      end

      # Creates a new shipment
      #
      # @param client [SynapsePayRest::Client]
      # @param user_id [String] id of the user to which the Shipment belongs
      # @param node_id [String] id of the node to which the Shipment belongs
      # @param subnet_id [String] id of the subnet to which the Shipment belongs
      # @param fee_node_id [String] ID of the Node to be charged for printing/shipping costs
      # @param cardholder_name [String] Name of the cardholder
      # @param delivery_method_name [String] Sets shipping speed of card
      # @param card_style_id [String] The numeric value representing the design style of the card
      # @param **options [Hash] Options to pass to Synapse's API
      #
      # @raise [SynapsePayRest::Error]
      #
      # @return [SynapsePayRest::Shipment]
      def create(client:, user_id:, node_id:, subnet_id:, fee_node_id:,
                 cardholder_name:, delivery_method_name:, card_style_id:, **options)
        payload["secondary_label"] = options["secondary_label"] if options["secondary_label"].present?

        response = client.shipments.create(user_id: user_id,
                                           node_id: node_id,
                                           subnet_id: subnet_id,
                                           payload: { fee_node_id: fee_node_id,
                                                      cardholder_name: cardholder_name,
                                                      delivery: delivery_method_name,
                                                      card_style_id: card_style_id })
        from_response(response)
      end

      # Builds a Shipment object from a response hash.
      #
      # @note Shouldn't need to call this directly.
      #
      def from_response(response)
        new(response.except("_id").merge(id: response["_id"]))
      end
    end
  end
end
