## Initialization

```ruby
require 'synapse_pay_rest'

require 'dotenv'
Dotenv.load

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
  development_mode: true, #
  # (optional) if true logs requests to stdout
  logging:          true,
  # (optional) file path to write logs to
  log_to:           nil
}

client = SynapsePayRest::Client.new(args)
# => #<SynapsePayRest::Client>

```

## User

#### All Users

```ruby

args = {
  client:   client,
  page:     nil, # (optional) uses API default unless specified
  per_page: nil, # (optional) uses API default unless specified
  query:    nil, # (optional) filters by name/email match
}

SynapsePayRest::User.all(args)
  # => [#<SynapsePayRest::User>, #<SynapsePayRest::User>, #<SynapsePayRest::User>]

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

#### Find a User by id

```ruby

user = SynapsePayRest::User.find(
  client: client,
  id:     '57e97ab786c2737f4ccd4dc1'
)
# => #<SynapsePayRest::User>

```

#### Update a User's Personal Info

Note: this returns a new, updated instance. It doesn't change the original.

```ruby

args = {
  login:                {email: 'newemail@gmail.com'}, # add a login email
  phone_number:         '415-555-5555',                # add a phone number
  legal_name:           'Big Bird',                    # add a legal name
  remove_phone_number:  '555-555-5555',                # remove a phone number
  remove_login:          nil                           # remove a login email
}

user = user.update(args)
# => #<SynapsePayRest::User> a new instance

```

#### Add CIP Base Document

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

user = user.create_base_document(args)
# => #<SynapsePayRest::User> a new instance

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

base_document = SynapsePayRest::BaseDocument.create(args)
# => #<SynapsePayRest::BaseDocument>

```

#### Add a Physical Document

```ruby

physical_doc = SynapsePayRest::PhysicalDocument.create(
  type: 'GOVT_ID',
  value: '/path/to/file.png'
)

base_document.add_physical_documents([physical_doc])
# => #<SynapsePayRest::BaseDocument> (self)

```

#### Add a Social Document

```ruby

social_doc = SynapsePayRest::SocialDocument.create(
  type: 'FACEBOOK',
  value: 'facebook.com/sankaet'
)

base_document.add_social_documents([social_doc])
# => #<SynapsePayRest::BaseDocument> (self)

```

#### Add a Virtual Document

```ruby

virtual_doc = SynapsePayRest::VirtualDocument.create(
  type: 'SSN',
  value: '3333'
)

base_document.add_virtual_documents([virtual_doc])
# => #<SynapsePayRest::BaseDocument> (self)

```

##### Answer KBA Questions for Virtual Document

```ruby



```

##### Update Existing Base Document

```ruby

new_govt_id_attachment = client.users.encode_attachment(file_path: FILE_PATH)

update_existing_docs_payload = {
  'documents' => [{
    'id' => base_document['id'],
    'email' => 'test3@test.com',
    'phone_number' => '555-5555',
    'physical_docs' => [{
      'document_value' => new_govt_id_attachment,
      'document_type' => 'GOVT_ID'
    }]
  }]
}

update_existing_docs_response = client.users.update(payload: update_existing_docs_payload)

```

## Node API Calls

##### Get All Nodes

```ruby

nodes_response = client.nodes.get


```

##### Add SYNAPSE-US Node

```ruby

synapse_node_payload = {
  'type' => 'SYNAPSE-US',
  'info' => {
    'nickname' => 'My Synapse Wallet'
  },
  'extra' => {
    'supp_id' => '123sa'
  }
}

synapse_node_response = client.nodes.add(payload: synapse_node_payload)


```

##### Add ACH-US node through account login

```ruby

login_payload = {
  'type' => 'ACH-US',
  'info' => {
    'bank_id' => 'synapse_good',
    'bank_pw' => 'test1234',
    'bank_name' => 'fake'
  }
}

login_response = client.nodes.add(payload: login_payload)


```

##### Verify ACH-US Node via MFA

```ruby

mfa_payload = {
  'access_token' => ACCESS_TOKEN_IN_LOGIN_RESPONSE,
  'mfa_answer' => 'test_answer'
}

mfa_response = client.nodes.verify(payload: mfa_payload)


```

##### Add ACH-US Node through Account and Routing Number Details

```ruby

acct_rout_payload = {
  'type' => 'ACH-US',
  'info' => {
    'nickname' => 'Ruby Library Savings Account',
    'name_on_account' => 'Ruby Library',
    'account_num' => '72347235423',
    'routing_num' => '051000017',
    'type' => 'PERSONAL',
    'class' => 'CHECKING'
  },
  'extra' => {
    'supp_id' => '123sa'
  }
}

acct_rout_response = client.nodes.add(payload: acct_rout_payload)


```

##### Verify ACH-US Node via Micro-Deposits

```ruby

micro_payload = {
  'micro' => [0.1,0.1]
}

micro_response = client.nodes.verify(node_id: NODE_ID, payload: micro_payload)

```

##### Delete a Node

```ruby

delete_response = client.nodes.delete(node_id: NODE_ID)

```

## Transaction API Calls

##### Get All Transactions

```ruby

transactions_response = client.trans.get(node_id: NODE_ID)

```

##### Create a Transaction

```ruby

trans_payload = {
  'to' => {
    'type' => 'SYNAPSE-US',
    'id' => '560adb4e86c27331bb5ac86e'
  },
  'amount' => {
    'amount' => 1.10,
    'currency' => 'USD'
  },
  'extra' => {
    'supp_id' => '1283764wqwsdd34wd13212',
    'note' => 'Deposit to bank account',
    'process_on' => 1,
    'ip' => '192.168.0.1'
  },
  'fees' => [{
    'fee' => 1.00,
    'note' => 'Facilitator Fee',
    'to' => {
      'id' => '55d9287486c27365fe3776fb'
    }
  }]
}

create_response = client.trans.create(node_id: NODE_ID, payload: trans_payload)

```

##### Get a Transaction

```ruby

transaction_response = client.trans.get(node_id: NODE_ID, trans_id: TRANS_ID)

```

##### Update Transaction

```ruby

update_payload = {
  'comment' =>  'hi'
}

update_response = client.trans.update(node_id: NODE_ID, trans_id: TRANS_ID, payload: update_payload)

```

##### Delete Transaction

```ruby

delete_trans_response = client.trans.delete(node_id: NODE_ID, trans_id: TRANS_ID)

```
