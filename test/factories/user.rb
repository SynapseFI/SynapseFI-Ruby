def test_user(client: test_client,
              logins: [{
                email: Faker::Internet.email,
                password: Faker::Internet.password,
                read_only: false
              }],
              phone_numbers: [Faker::PhoneNumber.cell_phone],
              legal_names: [Faker::Name.name],
              note: Faker::Hipster.sentence(3),
              supp_id: Faker::Number.number(10).to_s,
              is_business: false)
  SynapsePayRest::User.create(
    client: client,
    logins: logins,
    phone_numbers: phone_numbers,
    legal_names: legal_names,
    note: note,
    supp_id: supp_id,
    is_business: is_business
  )
end

def test_user_create_args(client: test_client,
                          logins: [{
                            email: Faker::Internet.email,
                            password: Faker::Internet.password,
                            read_only: false
                          }],
                          phone_numbers: [Faker::PhoneNumber.phone_number],
                          legal_names: [Faker::Name.name],
                          note: Faker::Hipster.sentence(3),
                          supp_id: Faker::Number.number(10).to_s,
                          is_business: false)
  {
    client: client,
    logins: logins,
    phone_numbers: phone_numbers,
    legal_names: legal_names,
    note: note,
    supp_id: supp_id,
    is_business: is_business
  }
end

def test_user_update_args(login: {
                            email: Faker::Internet.email,
                            password: Faker::Internet.password
                          },
                          read_only: false,
                          phone_number: Faker::PhoneNumber.phone_number,
                          legal_name: Faker::Name.name,
                          remove_phone_number: '123456',
                          remove_login: {email: 'asdf@gmail.com'})
  {
    login: login,
    read_only: read_only,
    phone_number: phone_number,
    legal_name: legal_name,
    remove_phone_number: remove_phone_number,
    remove_login: remove_login
  }
end

def test_user_with_base_document_with_three_documents
  args = test_base_document_args_with_three_documents
  # remove user key since create_base_document does not accept a user argument
  args.delete(:user)
  user = test_user
  base_doc = user.create_base_document(args)
  user = base_doc.user
end

def test_user_with_two_nodes
  user = test_user
  args = test_ach_us_create_via_bank_login_args(user: user)
  nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)
  user
end

def test_user_with_deposit_node
  user = test_user
  args = test_deposit_us_create_args(user: user)
  nodes = SynapsePayRest::DepositUsNode.create(args)
  user
end

def test_user_with_one_base_document
  args = test_base_document_args
  args.delete(:user)
  base_doc = test_user.create_base_document(args)
  user = base_doc.user
end

def test_user_with_base_doc
      args = {
      email:                'test@synapsepay.com',
      phone_number:         '415-555-5555',
      ip:                   '127.0.0.1',
      name:                 'test tester',
      aka:                  'test tester',
      entity_type:          'NOT_KNOWN',
      entity_scope:         'Doctor',
      birth_day:            3,
      birth_month:          1,
      birth_year:           1912,
      address_street:       '123 Synapse St',
      address_city:         'San Francisco',
      address_subdivision:  'CA',
      address_postal_code:  '94114',
      address_country_code: 'US'
      }
  base_doc = test_user.create_base_document(args)
  user = base_doc.user
end
