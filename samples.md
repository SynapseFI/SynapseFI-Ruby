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
  query:    nil,
}

users = SynapsePayRest::User.all(args)
  # => [#<SynapsePayRest::User>, #<SynapsePayRest::User>, ...]
```

#### Find a User by User ID

```ruby
user = SynapsePayRest::User.find(client: client, id: '57e97ab786c2737f4ccd4dc1')
# => #<SynapsePayRest::User>
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

##### Answer KBA Questions for Virtual Document

If a Virtual Document is returned with status **SUBMITTED|MFA_PENDING**, you will need to have the user answer some questions:

```ruby
# check for any virtual docs with SUBMITTED|MFA_PENDING status
virtual_doc = base_doc.virtual_documents.find do |doc|
  doc.status == 'SUBMITTED|MFA_PENDING'
end

question_set = virtual_doc.question_set
# => [#<SynapsePayRest::Question>, #<SynapsePayRest::Question>, ...]

# follow this flow for each question in question_set
question = question_set.first

question_text = question.question
# => "Which one of the following zip codes is associated with you?"

question.answers
# => {1=>"49230", 2=>"49209", 3=>"49268", 4=>"49532", 5=>"None Of The Above"}

question.choice = 1

# when finished answering all questions in question_set
virtual_doc = virtual_doc.submit_kba

# reassign this if you need the updated base doc
base_doc = virtual_doc.base_document
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
