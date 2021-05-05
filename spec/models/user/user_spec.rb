RSpec.describe SynapsePayRest::User do
  let(:oauth_response_body) do
    {
      oauth_key: 'foo123',
      expires_in: 10 # no idea what this type is
    }.to_json
  end
  let(:user_response_body) do
    {
      "_id" => "123",
      refresh_token: 'ref1',
      logins: [],
      phone_numbers: [],
      logal_name: [],
      permission: 'unverified',
      extra: {
        note: 'foo',
        supp_id: '123xyz',
        is_business: false,
        cip_tag: 1
      },
      documents: [] # base doc goes here
    }.to_json
  end
  let(:client) do
    SynapsePayRest::Client.new(client_id: '1', client_secret: '2', ip_address: "127.0.0.1")
  end

  def stub_refresh_token
    stub_request(:post, "https://uat-api.synapsefi.com/v3.1/oauth/123").with({
      body: "{\"refresh_token\":\"ref1\"}",
      headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Length'=>'24',
        'Content-Type'=>'application/json',
        'Host'=>'uat-api.synapsefi.com',
        'User-Agent'=>'rest-client/2.1.0 (darwin18.2.0 x86_64) ruby/2.6.0p0',
        'X-Sp-Gateway'=>'1|2',
        'X-Sp-User'=>'|',
        'X-Sp-User-Ip'=>'127.0.0.1'
      }
    }).
    to_return(status: 200, body: oauth_response_body, headers: {})
  end

  describe "get" do
    subject { SynapsePayRest::User.find(client: client, id: '123') }

    it "makes GET request with appropriate headers, and oauth POST" do
      stub_refresh_token
      stub_request(:get, "https://uat-api.synapsefi.com/v3.1/users/123?full_dehydrate=no").with({
        headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type'=>'application/json',
          'Host'=>'uat-api.synapsefi.com',
          'X-Sp-Gateway'=>'1|2',
          'X-Sp-User'=>'|',
          'X-Sp-User-Ip'=>'127.0.0.1'
        }
      }).
      to_return(status: 200, body: user_response_body, headers: {})
      subject
    end
  end

  describe "update" do
    subject { synapse_user.update(permission: "CLOSED", permission_code: "PLATFORM_REQUEST") }
    let(:synapse_user) { SynapsePayRest::User.new(client: client, id: '123') }

    context "permissions" do
      it "makes PATCH request with appropriate headers, " do
        stub_refresh_token
        stub_request(:patch, "https://uat-api.synapsefi.com/v3.1/users/123").with({
          body: "{\"refresh_token\":null,\"update\":{},\"extra\":{},\"permission\":\"CLOSED\",\"permission_code\":\"PLATFORM_REQUEST\"}",
          headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Length'=>'104',
            'Content-Type'=>'application/json',
            'Host'=>'uat-api.synapsefi.com',
            'User-Agent'=>'rest-client/2.1.0 (darwin18.2.0 x86_64) ruby/2.6.0p0',
            'X-Sp-Gateway'=>'1|2',
            'X-Sp-User'=>'|',
            'X-Sp-User-Ip'=>'127.0.0.1'
          }
        }).
        to_return(status: 200, body: user_response_body, headers: {})

        subject
      end
    end
  end
end
