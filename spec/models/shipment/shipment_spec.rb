require "support/shipment_mocks"

RSpec.configure do |c|
  c.include ShipmentMocks
end

RSpec.describe SynapsePayRest::Shipment do
  describe '.all' do
    it "gets a shipment" do
      client = SynapsePayRest::Client.new(client_id: "1", client_secret: "2", ip_address: "127.0.0.1")
      shipment_attributes = {
        user_id: "user_id_123",
        node_id: "node_id_123",
        subnet_id: "subnet_id_123"
      }
      mock_subnet_shipments
      mock_user_authentication

      result = SynapsePayRest::Shipment.all(client: client,
                                            **shipment_attributes).first

      expect(result.address.to_s).to include("1 MARKET ST STE 1000")
      expect(result.card_style_id).to include("card_style_id_123")
      expect(result.created_on).to_not be_nil
      expect(result.created_on).to_not be_nil
      expect(result.delivery_carrier).to_not be_nil
      expect(result.id).to eq("shipment_id_123")
      expect(result.status).to eq("BATCHED")
      expect(result.subnet_id).to eq("subnet_id_123")
      expect(result.tracking).to eq(3201877759)
    end
  end

  describe ".find" do
    it "gets a shipment" do
      client = SynapsePayRest::Client.new(client_id: "1", client_secret: "2", ip_address: "127.0.0.1")
      shipment_attributes = {
        user_id: "user_id_123",
        node_id: "node_id_123",
        subnet_id: "subnet_id_123",
        id: "shipment_id_123",
      }
      mock_existing_shipment
      mock_user_authentication

      result = SynapsePayRest::Shipment.find(client: client,
                                             **shipment_attributes)

      expect(result.address.to_s).to include("1 MARKET ST STE 1000")
      expect(result.card_style_id).to include("card_style_id_123")
      expect(result.created_on).to_not be_nil
      expect(result.created_on).to_not be_nil
      expect(result.delivery_carrier).to_not be_nil
      expect(result.id).to eq("shipment_id_123")
      expect(result.status).to eq("BATCHED")
      expect(result.subnet_id).to eq("subnet_id_123")
      expect(result.tracking).to eq(3201877759)
    end
  end

  describe ".create" do
    it "creates a shipment" do
      client = SynapsePayRest::Client.new(client_id: "1", client_secret: "2", ip_address: "127.0.0.1")
      params = {
        client: client,
        user_id: "user_id_123",
        node_id: "node_id_123",
        subnet_id: "subnet_id_123",
        fee_node_id: "5a8f017abdceaf004e5f23fd",
        cardholder_name: "TONA NUNEZ II",
        delivery_method_name: "STANDARD|TRACKING",
        card_style_id: "card_style_id_123",
      }
      mock_shipment_creation
      mock_user_authentication

      result = SynapsePayRest::Shipment.create(**params)

      expect(result.address.to_s).to include("1 MARKET ST STE 1000")
      expect(result.card_style_id).to include("card_style_id_123")
      expect(result.created_on).to_not be_nil
      expect(result.created_on).to_not be_nil
      expect(result.delivery_carrier).to_not be_nil
      expect(result.id).to eq("shipment_id_123")
      expect(result.status).to eq("CREATED")
      expect(result.subnet_id).to eq("subnet_id_123")
      expect(result.tracking).to eq(9421157643)
    end
  end
end
