# Setup

First, run `cp .env.sample .env` if you haven't already and make sure `CLIENT_ID`, `CLIENT_SECRET`, and `FINGERPRINT` are set.

Start a console that will load this gem and your settings from `.env` automatically.

```
$ ./bin/console
```

## Initialization

```ruby
args = {
  # synapse client_id
  client_id:        ENV.fetch('CLIENT_ID'),
  # synapse client_secret
  client_secret:    ENV.fetch('CLIENT_SECRET'),
  # a hashed value, either unique to user or static for app
  fingerprint:      ENV.fetch('FINGERPRINT'),
  # the user's IP
  ip_address:       '127.0.0.1',
  # (optional) requests go to sandbox endpoints if true
  development_mode: true,
  # (optional) if true logs requests to stdout
  logging:          true,
  # (optional) file path to write logs to
  log_to:           nil
  # (optional) URL used to proxy outbound requests
  proxy_url:        nil
}

client = SynapsePayRest::Client.new(args)
# => #<SynapsePayRest::Client>
```

## User Methods

#### All Users

```ruby
args = {
  client:   client,
  # (optional) uses API default unless specified
  page:     1,
  # (optional) uses API default of 20 unless specified, larger values take longer
  per_page: 50,
  # (optional) filters by name/email match
  query:    nil
}

users = SynapsePayRest::User.all(args)
  # => [#<SynapsePayRest::User>, #<SynapsePayRest::User>, ...]
```

#### Find a User by User ID

```ruby
user = SynapsePayRest::User.find(client: client, id: '57e97ab786c2737f4ccd4dc1')
# => #<SynapsePayRest::User>

# full_dehydrate: 'yes' optional, see docs for response example (https://docs.synapsepay.com/docs/get-user)
user = SynapsePayRest::User.find(client: client, id: '57e97ab786c2737f4ccd4dc1', full_dehydrate: 'yes')

sample full_dehydrate response (**note some fields will be 'nil' if full_dehydrate='no'):

#<SynapsePayRest: : User: 0x007fc2a2a62d88@client=
@base_url="https://uat-api.synapsefi.com/v3.1">>>,
@id="592f1dfa8384540026e39a95",
@refresh_token="refresh_WHGKxqmtJLlTrEgoS316dVAz24YD0jIfQCc7iBRF",
@logins=[
  {
    "email"=>"sankaet@synapsepay.com",
    "scope"=>"READ_AND_WRITE"
  }
],
@phone_numbers=[
  "sankaet@synapsepay.com",
  "901.942.8167"
],
@legal_names=[
  "Test User"
],
@permission="LOCKED",
@note="Interesting user",
@supp_id="122eddfgbeafrfvbbb",
@is_business=false,
@cip_tag=1,
@flag="NOT-FLAGGED",
@ips=[
  "127.0.0.1"
],
@oauth_key="oauth_V5jGaJMcwK4lrk0WFIZEqQXhRNPpoCSOxdUL30D9",
@expires_in="7200",
@base_documents=[
  #<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0@id="189d2fc37c1ee5694aa62f302bcd7c0efaae2c0229f45bfc8bb3470f6f7ab92a",
  @permission_scope="SEND|RECEIVE|1000|DAILY",
  @user=#<SynapsePayRest: : User: 0x007fc2a2a62d88...>,
  @email="test@test.com",
  @phone_number="111-111-1111",
  @ip="::1",
  @name="Charlie Brown",
  @aka=nil,
  @entity_type="M",
  @entity_scope="Arts & Entertainment",
  @birth_day=nil,
  @birth_month=nil,
  @birth_year=nil,
  @address_street="170 St Germain Ave",
  @address_city="SF",
  @address_subdivision="CA",
  @address_postal_code="94114",
  @address_country_code="US",
  @screening_results={
    "561"=>"NO_MATCH",
    "aucl"=>"NO_MATCH",
    "concern_location"=>"NO_MATCH",
    "dpl"=>"NO_MATCH",
    "dtc"=>"NO_MATCH",
    "el"=>"NO_MATCH",
    "eucl"=>"NO_MATCH",
    "fatf_non_cooperative_jurisdiction"=>"NO_MATCH",
    "fbi_bank_robbers"=>"NO_MATCH",
    "fbi_counter_intelligence"=>"NO_MATCH",
    "fbi_crimes_against_children"=>"NO_MATCH",
    "fbi_criminal_enterprise_investigations"=>"NO_MATCH",
    "fbi_cyber"=>"NO_MATCH",
    "fbi_domestic_terrorism"=>"NO_MATCH",
    "fbi_human_trafficking"=>"NO_MATCH",
    "fbi_murders"=>"NO_MATCH",
    "fbi_violent_crimes"=>"NO_MATCH",
    "fbi_wanted_terrorists"=>"NO_MATCH",
    "fbi_white_collar"=>"NO_MATCH",
    "fincen_red_list"=>"NO_MATCH",
    "fse"=>"NO_MATCH",
    "fto_sanctions"=>"NO_MATCH",
    "futures_sanctions"=>"NO_MATCH",
    "hkma_sanctions"=>"NO_MATCH",
    "hm_treasury_sanctions"=>"NO_MATCH",
    "isn"=>"NO_MATCH",
    "mas_sanctions"=>"NO_MATCH",
    "monitored_location"=>"NO_MATCH",
    "ns-isa"=>"NO_MATCH",
    "ofac_561_list"=>"NO_MATCH",
    "ofac_eo13645"=>"NO_MATCH",
    "ofac_fse"=>"NO_MATCH",
    "ofac_fse_ir"=>"NO_MATCH",
    "ofac_fse_sy"=>"NO_MATCH",
    "ofac_isa"=>"NO_MATCH",
    "ofac_ns_isa"=>"NO_MATCH",
    "ofac_plc"=>"NO_MATCH",
    "ofac_sdn"=>"NO_MATCH",
    "ofac_ssi"=>"NO_MATCH",
    "ofac_syria"=>"NO_MATCH",
    "ofac_ukraine_eo13662"=>"NO_MATCH",
    "osfi"=>"NO_MATCH",
    "pep"=>"NO_MATCH",
    "plc"=>"NO_MATCH",
    "primary_concern"=>"NO_MATCH",
    "sdn"=>"NO_MATCH",
    "ssi"=>"NO_MATCH",
    "tel_sanctions"=>"NO_MATCH",
    "ukcl"=>"NO_MATCH",
    "uvl"=>"NO_MATCH"
  },
  @physical_documents=[
    #<SynapsePayRest: : PhysicalDocument: 0x007fc2a2a61cf8@type="GOVT_ID",
    @id="b86950c0d9fd878ef38d5193a9c2d88c2957b5817556cce2fbab2201de40baa4",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090771,
    @document_value="https://cdn.synapsepay.com/uploads/2017/05/31/10591ef0-463a-11e7-bf7d-0230add36792.gif",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>
  ],
  @social_documents=[
    #<SynapsePayRest: : SocialDocument: 0x007fc2a2a61820@type="FACEBOOK",
    @id="0c32234c59b71311b0f3057635c206e6a0d39ecef0bc336fe2bb375c92968117",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090773,
    @document_value="https://www.facebook.com/sankaet",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>,
    #<SynapsePayRest: : SocialDocument: 0x007fc2a2a613c0@type="EMAIL",
    @id="2c45158f6431ca874bbe82f63d5905567854dde4d8b81539944e5779e5eee741",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090773,
    @document_value="test@test.com",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>,
    #<SynapsePayRest: : SocialDocument: 0x007fc2a2a61190@type="IP",
    @id="28d9177b22c127d9a51d8903893864accf6e553ac326704a4c0d585eaad2516a",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090773,
    @document_value="::1",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>,
    #<SynapsePayRest: : SocialDocument: 0x007fc2a2a60d58@type="PHONE_NUMBER",
    @id="54522fd5748d2dedeab0034a09f91f6e1337ea2181f6aaea0515b61cd52cb576",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090773,
    @document_value="111-111-1111",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>
  ],
  @virtual_documents=[
    #<SynapsePayRest: : VirtualDocument: 0x007fc2a2a608a8@type="SSN",
    @id="ee596c2896dddc19b76c07a184fe7d3cf5a04b8e94b9108190cac7890739017f",
    @value=nil,
    @status="SUBMITTED|VALID",
    @last_updated=1496260090768,
    @document_value="2222",
    @meta={
      "matches"=>{
        "address"=>"not_found",
        "dob"=>"not_found",
        "identification"=>"not_found"
      }
    },
    @base_document=#<SynapsePayRest: : BaseDocument: 0x007fc2a2a601f0...>>
  ]>
]>
```

#### Search for a User by Name/Email

```ruby
users = SynapsePayRest::User.search(client: client, query: 'Steven')
# => [#<SynapsePayRest::User>, #<SynapsePayRest::User>, ...]
```

#### Create User

```ruby
user_create_settings = {
  client:        client,
  logins:        [{email: 'steven@synapsepay.com'}],
  phone_numbers: ['555-555-5555'],
  legal_names:   ['Steven Broderick']
}

user = SynapsePayRest::User.create(user_create_settings)
# => #<SynapsePayRest::User>
```

#### Update a User's Personal Info

Note: this returns a new instance, so remember to reassign the user variable to the method output.

```ruby
user_update_settings = {
  login:                {email: 'newemail@gmail.com'}, # add a login email
  phone_number:         '415-555-5555',                # add a phone number
  legal_name:           'Big Bird',                    # add a legal name
  remove_phone_number:  '555-555-5555',                # remove a phone number
  remove_legal_name:    'Big Bird',                    # remove a legal name
  remove_login:          nil                           # remove a login email
}

# reassign user to the output because it returns a new instance
user = user.update(args)
# => #<SynapsePayRest::User>
```

#### Add CIP Base Document to a User

##### a) User#create_base_document

```ruby
args = {
  email:                'steven@synapsepay.com',
  phone_number:         '415-555-5555',
  ip:                   '127.0.0.1',
  name:                 'Steven Broderick',
  aka:                  'Steven Broderick',
  entity_type:          'NOT_KNOWN',
  entity_scope:         'Doctor',
  birth_day:            3,
  birth_month:          19,
  birth_year:           1912,
  address_street:       '123 Synapse St',
  address_city:         'San Francisco',
  address_subdivision:  'CA',
  address_postal_code:  '94114',
  address_country_code: 'US'
}

# reassign user to the output because it returns a new instance
base_document = user.create_base_document(args)
# => #<SynapsePayRest::BaseDocument>
```

##### b) BaseDocument#create

```ruby
args = {
  user:                 user,
  email:                'steven@synapsepay.com',
  phone_number:         '415-555-5555',
  ip:                   '127.0.0.1',
  name:                 'Steven Broderick',
  aka:                  'Steven Broderick',
  entity_type:          'NOT_KNOWN',
  entity_scope:         'Doctor',
  birth_day:            3,
  birth_month:          19,
  birth_year:           1912,
  address_street:       '123 Synapse St',
  address_city:         'San Francisco',
  address_subdivision:  'CA',
  address_postal_code:  '94114',
  address_country_code: 'US'
}

# reassign base_doc to the output because it returns a new instance
base_doc = SynapsePayRest::BaseDocument.create(args)
# => #<SynapsePayRest::BaseDocument>

# reassign user to this if you need the updated user
user = base_doc.user
```

#### Update User's Existing Base Document

```ruby
things_to_update = {
  entity_scope: 'Lawyer',
  birth_day:    22
}

base_doc = base_doc.update(things_to_update)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Physical Document to a CIP Base Document using image file path

```ruby
physical_doc = SynapsePayRest::PhysicalDocument.create(
  type:  'GOVT_ID',
  file_path: '/path/to/file.png'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_physical_documents(physical_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Physical Document to a CIP Base Document using image URL

```ruby
physical_doc = SynapsePayRest::PhysicalDocument.create(
  type:  'GOVT_ID',
  url: 'https://cdn.synapsepay.com/static_assets/logo@2x.png'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_physical_documents(physical_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Physical Document to a CIP Base Document using byte stream

```ruby
physical_doc = SynapsePayRest::PhysicalDocument.create(
  type:  'GOVT_ID',
  byte_stream: '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00...',
  mime_type: 'image/png'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_physical_documents(physical_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Physical Document to a CIP Base Document using base64

```ruby
physical_doc = SynapsePayRest::PhysicalDocument.create(
  type:  'GOVT_ID',
  value: 'data:image/png;base64,SUQs=='
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_physical_documents(physical_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Social Document to a CIP Base Document

```ruby
social_doc = SynapsePayRest::SocialDocument.create(
  type:  'FACEBOOK',
  value: 'facebook.com/sankaet'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_social_documents(social_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add a Virtual Document to a CIP Base Document

```ruby
virtual_doc = SynapsePayRest::VirtualDocument.create(
  type:  'SSN',
  value: '3333'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_virtual_documents(virtual_doc)
# => #<SynapsePayRest::BaseDocument>
```

#### Add and verify email and phone number 2fa

```ruby
social_doc = SynapsePayRest::SocialDocument.create(
  type:  'EMAIL_2FA',
  value: '1111111111'
)

# reassign base_doc to the output because it returns a new instance
base_doc = base_doc.add_social_documents(social_doc)
# => #<SynapsePayRest::BaseDocument>

# find the social doc with the same doc type
social_doc_email = base_doc.social_documents.find { |doc| doc.type == 'EMAIL_2FA' }

#verify the mfa_answer sent
social_doc_email.verify_2fa(mfa_answer: '123456' , value: '1111111111')
```

## Node Methods

#### All Nodes for a User

##### a) User#nodes

```ruby
nodes = user.nodes(page: 2, per_page: 5, type: 'ACH-US')
# => [#<SynapsePayRest::AchUsNode>, #<SynapsePayRest::AchUsNode>, ...]
```

##### b) Node#all

```ruby
nodes = SynapsePayRest::Node.all(user: user, page: 2, per_page: 5)
# => [#<SynapsePayRest::AchUsNode>, #<SynapsePayRest::SynapseUsNode>, ...]
```

#### Find a User's Node by Node ID

##### a) User#find_node

```ruby
node = user.find_node(id: '1a3efa1231as2f')
# => #<SynapsePayRest::EftNpNode>
```

##### b) Node#find

```ruby
node = SynapsePayRest::Node.find(user: user, id: '1a3efa1231as2f')
# => #<SynapsePayRest::EftNpNode>

# full_dehydrate: 'yes' (optional) returns all trans data on node
node = SynapsePayRest::Node.find(user: user, id: '1a3efa1231as2f', full_dehydrate: 'yes')

sample full_dehydrate response (**note some fields will be 'nil' if full_dehydrate='no'):

#<SynapsePayRest: : AchUsNode: 0x007f867e14b070@user=#<SynapsePayRest: 
@type="ACH-US",
@id="592f1e2d603964002f1b07f7",
@is_active=true,
@permission="LOCKED",
@nickname="SynapsePay Test Checking Account - 8901",
@name_on_account=" ",
@bank_long_name="CAPITAL ONE N.A.",
@bank_name="CAPITAL ONE N.A.",
@account_type="BUSINESS",
@account_class="CHECKING",
@account_number="12345678901",
@routing_number="031176110",
@address="PO BOX 85139, RICHMOND, VA, US",
@swift=nil,
@ifsc=nil,
@user_info={
  "account_id"=>"fd52bf51f0354335e634940139a006ef91d7e789c665857e9821656d18e7d012",
  "addresses"=>[
    {
      "city"=>"San Francisco",
      "state"=>"CA",
      "street"=>"3880 Castro St.",
      "zipcode"=>"94110"
    }
  ],
  "dob"=>"",
  "emails"=>[
    "test@synapsepay.com"
  ],
  "names"=>[
    "Test User"
  ],
  "phone_numbers"=>[
    "3937100934",
    "8958226574"
  ]
},
@transactions=[
  {
    "amount"=>233.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>212.0,
    "date"=>1397534400.0,
    "debit"=>false,
    "description"=>"CITI CARDS PPD:45367278097783",
    "pending"=>false
  },
  {
    "amount"=>317.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>8970.0,
    "date"=>1431835200.0,
    "debit"=>true,
    "description"=>"BK OF AM CRD PPD:42489094108452",
    "pending"=>true
  },
  {
    "amount"=>24.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>4779.0,
    "date"=>1404187200.0,
    "debit"=>false,
    "description"=>"CAPITAL ONE MOBILE PMT PPD:66159733534606",
    "pending"=>true
  },
  {
    "amount"=>53.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>7000.0,
    "date"=>1458100800.0,
    "debit"=>false,
    "description"=>"WF Credit Card PPD:15303774887880",
    "pending"=>true
  },
  {
    "amount"=>65.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>6400.0,
    "date"=>1466222400.0,
    "debit"=>false,
    "description"=>"CITI CARDS PPD:33669559685208",
    "pending"=>true
  },
  {
    "amount"=>185.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>5726.0,
    "date"=>1400040000.0,
    "debit"=>true,
    "description"=>"WF Credit Card PPD:12781852781478",
    "pending"=>true
  },
  {
    "amount"=>445.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>9337.0,
    "date"=>1457928000.0,
    "debit"=>true,
    "description"=>"BK OF AM CRD PPD:66137868896167",
    "pending"=>false
  },
  {
    "amount"=>39.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>6460.0,
    "date"=>1450242000.0,
    "debit"=>false,
    "description"=>"BK OF AM CRD PPD:63039795698738",
    "pending"=>false
  },
  {
    "amount"=>400.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>1732.0,
    "date"=>1481950800.0,
    "debit"=>false,
    "description"=>"AMEX EPAYMENT PPD:18493222207835",
    "pending"=>true
  },
  {
    "amount"=>112.0,
    "category"=>{
      "primary"=>"",
      "subcategory"=>""
    },
    "current_balance"=>7645.0,
    "date"=>1417928400.0,
    "debit"=>true,
    "description"=>"AMEX EPAYMENT PPD:28509869400705",
    "pending"=>false
  }
],
@timeline=[
  {
    "date"=>1496260140541,
    "note"=>"Node created."
  },
  {
    "date"=>1496260142204,
    "note"=>"Unable to send micro deposits as node allowed is not CREDIT."
  },
  {
    "date"=>1496260420927,
    "note"=>"User locked. Thus node 'allowed' changed to LOCKED."
  }
],
@billpay_info=[
  {
    "amount"=>160.05,
    "duration"=>{
      "meta"=>{
        "remaining_payments"=>71,
        "total_payments"=>72
      },
      "type"=>"SPECIFIC_NUM_PAYMENTS"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_week"=>"TUESDAY"
      },
      "type"=>"WEEKLY"
    },
    "frequency_meta"=>{
      "day_of_week"=>{
        "type"=>"Weekday",
        "value"=>2
      }
    },
    "frequency_type"=>"WEEKLY",
    "memo"=>"Payment to card ending 9990",
    "pay_from_account"=>"254648bb700253e150a428597b8f7c0ca33e2e94257f79ecfa2a00feb422c5e2",
    "payee"=>{
      "account_number"=>"2507657178062104",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"1716 Castro St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"JP Morgan Chase",
      "nickname"=>"Payment to Joe's United card",
      "phone_number"=>"6424032051"
    },
    "start_date"=>"2017-11-07"
  },
  {
    "amount"=>185.59,
    "duration"=>{
      "type"=>"UNTIL_STOPPED"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_month"=>24
      },
      "type"=>"EVERY_THREE_MONTHS"
    },
    "frequency_meta"=>{
      "day_of_month"=>24
    },
    "frequency_type"=>"EVERY_THREE_MONTHS",
    "memo"=>"Payment to card ending 7770",
    "pay_from_account"=>"fd52bf51f0354335e634940139a006ef91d7e789c665857e9821656d18e7d012",
    "payee"=>{
      "account_number"=>"8609794239422625",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"7097 Castro St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"American Express",
      "nickname"=>"Old AMEX card",
      "phone_number"=>"3716731060"
    },
    "start_date"=>"2017-06-07"
  },
  {
    "amount"=>165.0,
    "duration"=>{
      "type"=>"UNTIL_STOPPED"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_week"=>"THURSDAY"
      },
      "type"=>"EVERY_TWO_WEEKS"
    },
    "frequency_meta"=>{
      "day_of_week"=>{
        "type"=>"Weekday",
        "value"=>4
      }
    },
    "frequency_type"=>"EVERY_TWO_WEEKS",
    "memo"=>"Monthly Cable Payment",
    "pay_from_account"=>"254648bb700253e150a428597b8f7c0ca33e2e94257f79ecfa2a00feb422c5e2",
    "payee"=>{
      "account_number"=>"5673862380187205",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"5205 Castro St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"Comcast Cable",
      "nickname"=>"cable at rental home",
      "phone_number"=>"9219013643"
    },
    "start_date"=>"2017-08-07"
  },
  {
    "amount"=>42.46,
    "duration"=>{
      "meta"=>{
        "remaining_payments"=>27,
        "total_payments"=>87
      },
      "type"=>"SPECIFIC_NUM_PAYMENTS"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_month"=>21
      },
      "type"=>"EVERY_MONTH"
    },
    "frequency_meta"=>{
      "day_of_month"=>21
    },
    "frequency_type"=>"EVERY_MONTH",
    "memo"=>"Payment to card ending 7770",
    "pay_from_account"=>"fd52bf51f0354335e634940139a006ef91d7e789c665857e9821656d18e7d012",
    "payee"=>{
      "account_number"=>"2867054184778944",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"1022 Fulton St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"American Express",
      "nickname"=>"Old AMEX card",
      "phone_number"=>"4737047304"
    },
    "start_date"=>"2017-05-05"
  },
  {
    "amount"=>233.8,
    "duration"=>{
      "meta"=>{
        "remaining_payments"=>0,
        "total_payments"=>19
      },
      "type"=>"SPECIFIC_NUM_PAYMENTS"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_week"=>"THURSDAY"
      },
      "type"=>"EVERY_TWO_WEEKS"
    },
    "frequency_meta"=>{
      "day_of_week"=>{
        "type"=>"Weekday",
        "value"=>4
      }
    },
    "frequency_type"=>"EVERY_TWO_WEEKS",
    "memo"=>"Payment to card ending 7770",
    "pay_from_account"=>"254648bb700253e150a428597b8f7c0ca33e2e94257f79ecfa2a00feb422c5e2",
    "payee"=>{
      "account_number"=>"4712680119518462",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"2681 Market St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"American Express",
      "nickname"=>"Old AMEX card",
      "phone_number"=>"4424477394"
    },
    "start_date"=>"2017-12-14"
  },
  {
    "amount"=>32.64,
    "duration"=>{
      "meta"=>{
        "end_date"=>"2020-08-08"
      },
      "type"=>"SPECIFIC_DATE"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_month"=>25
      },
      "type"=>"EVERY_SIX_MONTHS"
    },
    "frequency_meta"=>{
      "day_of_month"=>25
    },
    "frequency_type"=>"EVERY_SIX_MONTHS",
    "memo"=>"Payment to card ending 9990",
    "pay_from_account"=>"254648bb700253e150a428597b8f7c0ca33e2e94257f79ecfa2a00feb422c5e2",
    "payee"=>{
      "account_number"=>"3709218202306843",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"6950 Market St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"JP Morgan Chase",
      "nickname"=>"Payment to Joe's United card",
      "phone_number"=>"4914993163"
    },
    "start_date"=>"2017-09-13"
  },
  {
    "amount"=>64.89,
    "duration"=>{
      "meta"=>{
        "remaining_payments"=>23,
        "total_payments"=>78
      },
      "type"=>"SPECIFIC_NUM_PAYMENTS"
    },
    "frequency"=>{
      "meta"=>{
        "day_of_month"=>20
      },
      "type"=>"EVERY_MONTH"
    },
    "frequency_meta"=>{
      "day_of_month"=>20
    },
    "frequency_type"=>"EVERY_MONTH",
    "memo"=>"Payment to card ending 9990",
    "pay_from_account"=>"fd52bf51f0354335e634940139a006ef91d7e789c665857e9821656d18e7d012",
    "payee"=>{
      "account_number"=>"1271243682221748",
      "address"=>{
        "city"=>"San Francisco",
        "state"=>"CA",
        "street"=>"4047 Market St.",
        "zipcode"=>"94110"
      },
      "email"=>"example@email.com",
      "entity_type"=>"BUSINESS",
      "name"=>"JP Morgan Chase",
      "nickname"=>"Payment to Joe's United card",
      "phone_number"=>"3260578586"
    },
    "start_date"=>"2017-10-05"
  }
],
@transaction_analysis={
  "bank_fees"=>[
    {
      "avg_amount"=>3.75,
      "avg_days_between_fees"=>35.0,
      "avg_monthly_amount"=>3.75,
      "days"=>35.0,
      "fee"=>"ATM",
      "fee_frequency_per_month"=>1.0
    },
    {
      "avg_amount"=>362.5,
      "avg_days_between_fees"=>3.0,
      "avg_monthly_amount"=>3443.74,
      "days"=>393.0,
      "fee"=>"Wire",
      "fee_frequency_per_month"=>12.2
    }
  ],
  "cash"=>{
    "cash_in"=>{
      "avg_days_between_deposits"=>60.0,
      "avg_deposit"=>500.31,
      "avg_deposits_per_month"=>2.1,
      "avg_monthly_deposit"=>875.54,
      "days"=>361.0
    },
    "cash_out"=>{
      "avg_days_between_withdrawals"=>14.2,
      "avg_monthly_withdrawal"=>1677.96,
      "avg_withdrawal"=>645.37,
      "avg_withdrawals_per_month"=>3.2,
      "days"=>356.0
    }
  },
  "credit_cards"=>[
    {
      "avg_days_between_payments"=>10.0,
      "avg_monthly_payment"=>810.56,
      "avg_payment"=>311.76,
      "avg_payments_per_month"=>2.8,
      "days"=>120.0,
      "issuer"=>"Citi"
    },
    {
      "avg_days_between_payments"=>13.9,
      "avg_monthly_payment"=>399.66,
      "avg_payment"=>165.38,
      "avg_payments_per_month"=>2.8,
      "days"=>390.0,
      "issuer"=>"Discover"
    }
  ],
  "days"=>393.0,
  "income_streams"=>[
    {
      "active"=>false,
      "days"=>56.0,
      "monthly_frequency"=>2.0,
      "monthly_income"=>105.39,
      "name"=>"THE COLLEGE OF NJ",
      "period"=>14.0,
      "period_income"=>63.24
    }
  ]
},
@email_match="match",
@name_match="no_match",
@phonenumber_match="no_match",
@balance="800.00",
@currency="USD",
@supp_id="",
@gateway_restricted=nil>
```

#### Create ACH-US Node(s) via Bank Login

Returns a collection of `AchUsNode`s associated with the account unless bank requires MFA. Can also use `AchUsNode.create_via_bank_login` with the addition of a `user` argument.

```ruby
login_info = {
  bank_name: 'fake',
  username:  'synapse_good',
  password:  'test1234'
}

nodes = user.create_ach_us_nodes_via_bank_login(login_info)
# => [#<SynapsePayRest::AchUsNode>, ...] if no MFA
# => SynapsePayRest::UnverifiedNode if MFA
```

##### Verify Bank Login MFA

If the bank requires MFA, you will need to resolve the MFA question(s):

```ruby
nodes.mfa_verified
# => false

nodes.mfa_message
# => "Enter the code we texted to your phone number."

nodes = nodes.answer_mfa('test_answer')
# => [#<SynapsePayRest::AchUsNode>, ...] if successful
# => SynapsePayRest::UnverifiedNode if additional MFA question (check node.mfa_message)
# => raises SynapsePayRest::Error if incorrect answer

nodes.mfa_verified
# => true
```

##### Verify Bank Login MFA without existing node object

If you are unable to finish MFA in one session with `AchUsNode.create_via_bank_login`, you can create another unverified node with just the access token. Use `AchUsNode.create_via_bank_login_mfa` with the addition of an `access_token` argument.

```ruby
unverified_node = user.create_ach_us_nodes_via_bank_login_mfa(access_token:)
```

Then proceed to resolve the MFA question(s) as before:

```ruby

nodes = nodes.answer_mfa('test_answer')
# => [#<SynapsePayRest::AchUsNode>, ...] if successful
# => SynapsePayRest::UnverifiedNode if additional MFA question (check node.mfa_message)
# => raises SynapsePayRest::Error if incorrect answer

nodes.mfa_verified
# => true
```

#### Create ACH-US Node via Account/Routing Number

Can also use `AchUsNode.create` with the addition of a `user` argument.

```ruby
account_info = {
  nickname:       'Primary Joint Checking',
  account_number: '2222222222',
  routing_number: '051000017',
  account_type:   'PERSONAL',
  account_class:  'CHECKING'
}

node = user.create_ach_us_node(account_info)
# => #<SynapsePayRest::AchUsNode>
```

##### Verify Microdeposits

`ACH-US Node`s added by account/routing must be verified with microdeposits:

```ruby
node = node.verify_microdeposits(amount1: 0.1, amount2: 0.1)
# => #<SynapsePayRest::AchUsNode>
```

#### Create CHECK-US Node

```ruby
check_info = {
  type:                   'CHECK-US',
  nickname:               'test check-us',
  payee_name:             'Test McTest',
  address_street:         '1 Market St',
  address_city:           'San Francisco',
  address_subdivision:    'CA',
  address_country_code:   'US',
  address_postal_code:    '94105'
}

node = user.create_check_us_node(check_info)
# => #<SynapsePayRest::CheckUsNode>
```

#### Create INTERCHANGE-US Node

```ruby
node_info = {
  nickname:               'my debit card',
  card_number:            [string of encrypted card number],
  exp_date:               [string of encrypted exp date (YYYYMM)],
  document_id:            [string of base doc id],
}

node = user.create_interchange_us_node(node_info)
# => #<SynapsePayRest::InterchangeUsNode>
```

#### Create CARD-US Node

```ruby
id = base_document.id

node_info = {
  nickname: 'Debit Card',
  document_id: id,
  card_type: 'PHYSICAL',
  card_style_id: '550' #optional -- only pass this in if there are multiple styles
}

card_node = user.create_card_us_node(node_info)
# => #<SynapsePayRest::CardUsNode>
```

#### Reorder CARD-US Node

```ruby
node = card_node.reorder_card
# => #<SynapsePayRest::CardUsNode>
```

#### Reissue CARD-US Node

```ruby
node = card_node.reissue_card
# => #<SynapsePayRest::CardUsNode>
```

#### Update CARD-US Preferences

```ruby
card_prefs = {
    allow_foreign_transactions: true,
    atm_withdrawal_limit: 6000,
    max_pin_attempts: 4,
    pos_withdrawal_limit: 100,
    security_alerts: false
}

node = node.update_preferences(card_prefs)
# => #<SynapsePayRest::CardUsNode>
```

#### Deactivate a Node

This deactivates the node. It does not automatically cancel any transactions already underway.

```ruby
node.deactivate
# => :success
```


## Transaction Methods

#### All Transactions from a Node

##### a) Node#transactions

```ruby
transactions = node.transactions(page: 1, per_page: 15)
# => [#<SynapsePayRest::Transaction>, #<SynapsePayRest::Transaction>, ...]
```

##### b) Transaction#all

```ruby
transactions = SynapsePayRest::Transaction.all(node: node, page: 1, per_page: 15)
# => [#<SynapsePayRest::Transaction>, #<SynapsePayRest::Transaction>, ...]
```

#### Find a Node's Transaction by ID

##### a) Node#find_transaction

```ruby
transaction = node.find_transaction(id: '167e11516')
# => #<SynapsePayRest::Transaction>
```

##### b) Transaction#find

```ruby
transaction = SynapsePayRest::Transaction.find(node: node, id: '57fab7d186c2733525dd7eac')
# => #<SynapsePayRest::Transaction>
```

#### Create a Transaction

##### a) Node#create_transaction

```ruby
transaction_settings = {
  to_type:  'ACH-US',
  to_id:    '57fab4b286c2732210c73486',
  amount:   50.0,
  currency: 'USD',
  ip:       '127.0.0.1'
}

transaction = node.create_transaction(transaction_settings)
# => #<SynapsePayRest::Transaction>
```

##### b) Transaction#create

```ruby
transaction_settings = {
  node:     node,
  to_type:  'ACH-US',
  to_id:    '57fab4b286c2732210c73486',
  amount:   50.0,
  currency: 'USD',
  ip:       '127.0.0.1'
}

transaction = SynapsePayRest::Transaction.create(transaction_settings)
# => #<SynapsePayRest::Transaction>
```

#### Add a Comment to a Transaction's Status

```ruby
transaction = transaction.add_comment('this is my favorite transaction')
# => #<SynapsePayRest::Transaction>
```

#### Cancel a Transaction

```ruby
transaction = transaction.cancel
# => #<SynapsePayRest::Transaction>
```

## Subnet Methods

#### All Subnets from a Node

##### a) Node#subnets

```ruby
subnets = node.subnets(page: 1, per_page: 15)
# => [#<SynapsePayRest::Subnet>, #<SynapsePayRest::Subnet>, ...]
```

##### b) Subnet#all

```ruby
subnets = SynapsePayRest::Subnet.all(node: node, page: 1, per_page: 15)
# => [#<SynapsePayRest::Subnet>, #<SynapsePayRest::Subnet>, ...]
```

#### Find a Node's Subnet by ID

##### a) Node#find_subnet

```ruby
subnet= node.find_subnet(id: '167e11516')
# => #<SynapsePayRest::Subnet>
```

##### b) Subnet#find

```ruby
subnet = SynapsePayRest::Subnet.find(node: node, id: '57fab7d186c2733525dd7eac')
# => #<SynapsePayRest::Subnet>
```

#### Create a Subnet

##### a) Node#create_subnet

```ruby
subnet_settings = {
  "nickname":"Test AC/RT"
}

subnet = node.create_subnet(subnet_settings)
# => #<SynapsePayRest::Subnet>
```

##### b) Subnet#create

```ruby
subnet_settings = {
  "nickname":"Test AC/RT"
}

subnet = SynapsePayRest::Subnet.create(subnet_settings)
# => #<SynapsePayRest::Subnet>
```

#### To lock a Subnet

```ruby
subnet = subnet.lock
# => #<SynapsePayRest::Subnet>
```

## Issue Public Key Method

#### Issue Public Key From Client

##### a) Client#issue_public_key

```ruby
public_key = client.issue_public_key(scope: ‘CLIENT|CONTROLS’)
# => #<SynapsePayRest::Public_key>
```

##### b) PublicKey#issue

```ruby
public_key = SynapsePayRest::PublicKey.issue(client: client, scope: ‘CLIENT|CONTROLS')
# => #<SynapsePayRest::Public_key>
```

## Crypto Quote Method

#### Get Crypto Quote From Client

##### a) Client#get_crypto_quotes

```ruby
crypto_quotes = client.get_crypto_quotes
# => #<SynapsePayRest::CryptoQuote>
```

##### b) CryptoQuote#get

```ruby
crypto_quote = SynapsePayRest::CryptoQuote.get(client: client)
# => #<SynapsePayRest::CryptoQuote>
```

## Institution Method

#### Get Institutions

##### a) Institutions#all

```ruby
institutions = SynapsePayRest::Institution.all(client: client)
# => [#<SynapsePayRest::Institution>, #<SynapsePayRest::Institution>, ...]
```

## Locate ATM Method

#### Locate nearby ATMs with lat/lon or zipcode

##### a) ATM#locate

```ruby
atm_info = {
  client: client,
  lat: '37.764832',
  lon: '-122.419304',
  radius: '5',
  page: 1,
  per_page: 10
   }

atms = SynapsePayRest::Atm.locate(atm_info)
# => [#<SynapsePayRest::Atm>, #<SynapsePayRest::Atm>, ...]
```

##### b) ATM#locate

```ruby
atm_args = {
  client: client,
  zip: '95131',
  radius: '10',
  page: 1,
  per_page: 10
   }

atms = SynapsePayRest::Atm.locate(atm_args)
# => [#<SynapsePayRest::Atm>, #<SynapsePayRest::Atm>, ...]
```

## Get Statement Method

#### Get Statement By User or Node

##### a) Statement#by_user

```ruby
user = SynapsePayRest::User.find(client: client, id: '5b5f95dc83403300fbc76')

statements = SynapsePayRest::Statement.by_user(client: client, user: user)
# => [#<SynapsePayRest::Statement>, #<SynapsePayRest::Statement>, ...]
```

##### b) Statement#by_node

```ruby
user = SynapsePayRest::User.find(client: client, id: '5b5f95dc83403300fbc76')

node = user.find_node(id: '5b634a241jngjnei04c7b39b1')



statements = SynapsePayRest::Statement.by_node(client: client, node: node)
# => [#<SynapsePayRest::Statement>, #<SynapsePayRest::Statement>, ...]
```
##### c) User#get_statement

```ruby
user = SynapsePayRest::User.find(client: client, id: '5b5f95dc83403300fbc76')

statements = user.get_statement()
# => [#<SynapsePayRest::Statement>, #<SynapsePayRest::Statement>, ...]
```
##### d) Node#get_statement

```ruby
user = SynapsePayRest::User.find(client: client, id: '5b5f95dc83403300fbc76')
node = user.find_node(id: '5b634a241jngjnei04c7b39b1')

statements = node.get_statement()
# => [#<SynapsePayRest::Statement>, #<SynapsePayRest::Statement>, ...]
```