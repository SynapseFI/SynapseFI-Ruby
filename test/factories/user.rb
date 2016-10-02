def test_user(client: test_client,
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
  SynapsePayRest::User.create(
    client: test_client,
    logins: [{
      email: Faker::Internet.email, 
      password: Faker::Internet.password, 
      read_only: false
    }],
    phone_numbers: [Faker::PhoneNumber.phone_number],
    legal_names: [Faker::Name.name],
    note: Faker::Hipster.sentence(3),
    supp_id: Faker::Number.number(10).to_s,
    is_business: false
  )
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

def test_user_with_base_document_with_three_documents
  args = test_base_document_fields_with_three_documents
  # remove user key since create_base_document does not accept a user argument
  args.delete(:user)
  user = test_user
  user.create_base_document(args)
  user
end

def test_user_with_two_nodes
  user = test_user
  args = test_ach_us_create_via_login_args(user: user)
  nodes = SynapsePayRest::AchUsNode.create_via_bank_login(args)
  user
end

def test_user_with_one_base_document
  args = test_base_document_fields
  args.delete(:user)
  test_user.create_base_document(args)
end
