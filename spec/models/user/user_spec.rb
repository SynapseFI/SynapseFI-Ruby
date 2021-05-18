RSpec.describe SynapsePayRest::User do
  let(:user_response_body) do
    {
      "_id" => "user_id_123",
      refresh_token: "ref1",
      logins: [],
      phone_numbers: [],
      logal_name: [],
      permission: "unverified",
      extra: {
        note: "foo",
        supp_id: "123xyz",
        is_business: false,
        cip_tag: 1,
      },
      documents: [], # base doc goes here
    }.to_json
  end
  let(:client) do
    SynapsePayRest::Client.new(client_id: "1", client_secret: "2", ip_address: "127.0.0.1")
  end

  describe "get" do
    it "makes GET request with appropriate headers, and oauth POST" do
      mock_user_authentication

      result = SynapsePayRest::User.find(client: client, id: "user_id_123")

      expect(result.id).to eq("user_id_123")
      expect(result.refresh_token).to eq("ref1")
    end
  end

  describe "update" do
    context "permissions" do
      it "makes PATCH request with appropriate headers, " do
        mock_user_authentication
        synapse_user = SynapsePayRest::User.new(client: client, id: "user_id_123")
        stub_request(:patch, "https://uat-api.synapsefi.com/v3.1/users/user_id_123").
          with({
            body: "{\"refresh_token\":null,\"update\":{},\"extra\":{},\"permission\":\"CLOSED\",\"permission_code\":\"PLATFORM_REQUEST\"}",
            headers: {
              "Accept" => "application/json",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Content-Length" => "104",
              "Content-Type" => "application/json",
              "Host" => "uat-api.synapsefi.com",
              "User-Agent" => "rest-client/2.1.0 (darwin20.3.0 x86_64) ruby/2.6.6p146",
              "X-Sp-Gateway" => "1|2",
              "X-Sp-User" => "|",
              "X-Sp-User-Ip" => "127.0.0.1",
            },
          }).
          to_return(status: 200, body: user_response_body, headers: {})

        result = synapse_user.update(permission: "CLOSED", permission_code: "PLATFORM_REQUEST")

        expect(result.id).to eq("user_id_123")
        expect(result.refresh_token).to eq("ref1")
      end
    end
  end
end
