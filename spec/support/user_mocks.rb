module UserMocks
  def mock_user_authentication
    stub_request(:post, "https://uat-api.synapsefi.com/v3.1/oauth/user_id_123")
      .with({
        body: "{\"refresh_token\":\"ref1\"}",
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Length" => "24",
          "Content-Type" => "application/json",
          "Host" => "uat-api.synapsefi.com",
          "X-Sp-Gateway" => "1|2",
          "X-Sp-User" => "|",
          "X-Sp-User-Ip" => "127.0.0.1",
        },
      })
      .to_return(
        status: 200,
        body: {
          oauth_key: "foo123",
          expires_in: 10, # no idea what this type is
        }.to_json,
        headers: {},
      )

    stub_request(:get, "https://uat-api.synapsefi.com/v3.1/users/user_id_123?full_dehydrate=no")
      .with({
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/json",
          "Host" => "uat-api.synapsefi.com",
          "X-Sp-Gateway" => "1|2",
          "X-Sp-User" => "|",
          "X-Sp-User-Ip" => "127.0.0.1",
        },
      })
      .to_return(
        status: 200,
        body: {
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
        }.to_json,
        headers: {},
      )
  end
end
