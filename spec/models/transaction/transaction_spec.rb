RSpec.describe SynapsePayRest::Transaction do
  describe "create" do
    it "does" do
      ip = "127.0.0.1"
      client = SynapsePayRest::Client.new(client_id: '1', client_secret: '2', ip_address: ip)
      # http_client = SynapsePayRest::HTTPClient.new(base_url: 'http://api.foo.com', fingerprint: '123', client_id: '1', client_secret: '2', ip_address: ip)
      user = SynapsePayRest::User.new(client: client)
      node = SynapsePayRest::BaseNode.new(user: user)
      to_type = "ach_us"
      to_id = "123"
      idempotency_key = "6308897764d23f10e8e6"

      response = {
        "_id" => "5bf33a40b95dfb00bfdcbe93",
        amount: { amount: 10.12, currency: 'USD' },
        client: { id: '1', name: 'test' },
        extra: {
          created_on: Time.now.to_i * 1000,
          ip: ip,
          latlon: nil, # maybe not nil in prod,
          note: nil,
          process_on: nil,
          same_day: false,
          supp_id: '123',
          webhook: nil, # maybe not nil in prod?
          other: {
            dispute_form: '',
            disputed: false
          }
        },
        fees: [ { fee: 1, note: 'foo', to: { id: '3434' } } ], # not sure of actual fees structure
        recent_status: "settled",
        timeline: [{event: :foo, status: "settled"}],
        from: { "_id": "123" },
        to: { type: "ach_us", id: "3" },
      }

      stub_request(:post, "https://uat-api.synapsefi.com/v3.1/users//nodes//trans").
        with(body: "{\"to\":{\"type\":\"ach_us\",\"id\":\"123\"},\"amount\":{\"amount\":10.12,\"currency\":\"USD\"},\"extra\":{\"ip\":\"127.0.0.1\"}}",
             headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Length'=>'105',
          'Content-Type'=>'application/json',
          'Host'=>'uat-api.synapsefi.com',
          'X-Sp-Gateway'=>'1|2',
          'X-Sp-Idempotency-Key'=>'6308897764d23f10e8e6',
          'X-Sp-User'=>'|',
          'X-Sp-User-Ip'=>'127.0.0.1'
        }).
        to_return(status: 200, body: response.to_json, headers: {})

        SynapsePayRest::Transaction.create(node: node, to_type: to_type, to_id: to_id, amount: 10.12, currency: "USD", ip: ip, idempotency_key: idempotency_key)
    end
  end
end
