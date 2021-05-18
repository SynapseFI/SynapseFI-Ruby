module ShipmentMocks
  def mock_existing_shipment
    stub_request(:get, "https://uat-api.synapsefi.com/v3.1/users/user_id_123/nodes/node_id_123/subnets/subnet_id_123/ship/shipment_id_123")
      .to_return(
        status: 200,
        body: {
          "_id": "shipment_id_123",
          "address": {
            "address_care_of": "",
            "address_city": "SAN FRANCISCO",
            "address_country_code": "US",
            "address_postal_code": "94105",
            "address_street": "1 MARKET ST STE 1000",
            "address_subdivision": "CA",
          },
          "card_style_id": "card_style_id_123",
          "created_on": 1620671382558,
          "delivery": "STANDARD|TRACKING",
          "delivery_carrier": "6070 Poplar Avenue, Suite 100 Memphis, Tennessee 38119",
          "name": "foo bar",
          "secondary_label": false,
          "status": "BATCHED",
          "subnet_id": "subnet_id_123",
          "tracking": 3201877759,
        }.to_json,
        headers: {},
      )
  end

  def mock_shipment_creation
    stub_request(:post, "https://uat-api.synapsefi.com/v3.1/users/user_id_123/nodes/node_id_123/subnets/subnet_id_123/ship")
      .to_return(
        status: 200,
        body: {
          "_id": "shipment_id_123",
          "address": {
            "address_care_of": "",
            "address_city": "SAN FRANCISCO",
            "address_country_code": "US",
            "address_postal_code": "94105",
            "address_street": "1 MARKET ST STE 1000",
            "address_subdivision": "CA",
          },
          "card_style_id": "card_style_id_123",
          "created_on": 1621261460854,
          "delivery": "STANDARD|TRACKING",
          "delivery_carrier": "6070 Poplar Avenue, Suite 100 Memphis, Tennessee 38119",
          "name": "Foo Bar",
          "node_id": "node_id_123",
          "secondary_label": false,
          "status": "CREATED",
          "subnet_id": "subnet_id_123",
          "tracking": 9421157643,
          "transaction_id": "transaction_id_123",
        }.to_json,
        headers: {},
      )
  end
end
