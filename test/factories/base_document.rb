def test_base_document_args(user: test_user,
                            email: Faker::Internet.email,
                            phone_number: Faker::PhoneNumber.phone_number,
                            ip: '127.0.0.1',
                            legal_name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
                            aka: Faker::Name.name,
                            entity_type: %w(M F).sample,
                            entity_scope: 'Arts & Entertainment',
                            birth_day: rand(1..28),
                            birth_month: rand(1..12),
                            birth_year: rand(1930..1996),
                            address_street: Faker::Address.street_name,
                            address_city: Faker::Address.city,
                            address_subdivision: Faker::Address.state_abbr,
                            address_postal_code: Faker::Address.zip,
                            address_country_code: Faker::Address.country_code)
  {
    user: user,
    email: email,
    phone_number: phone_number,
    ip: ip,
    name: legal_name,
    aka: aka,
    entity_type: entity_type,
    entity_scope: entity_scope,
    birth_day: birth_day,
    birth_month: birth_month,
    birth_year: birth_year,
    address_street: address_street,
    address_city: address_city,
    address_subdivision: address_subdivision,
    address_postal_code: address_postal_code,
    address_country_code: address_country_code
  }
end

def test_base_document_args_with_three_documents(physical_documents: [test_physical_document],
                                                 social_documents: [test_social_document],
                                                 virtual_documents: [test_virtual_document])
  test_base_document_args.merge({
    physical_documents: physical_documents,
    social_documents:   social_documents,
    virtual_documents:  virtual_documents
  })
end

def test_base_document_args_with_six_documents(physical_documents: [test_physical_document, test_physical_document],
                                               social_documents: [test_social_document, test_social_document],
                                               virtual_documents: [test_virtual_document, test_virtual_document])
  test_base_document_args.merge({
    physical_documents: physical_documents,
    social_documents:   social_documents,
    virtual_documents:  virtual_documents
  })
end

def test_base_document_with_three_documents
  SynapsePayRest::BaseDocument.create(test_base_document_args_with_three_documents)
end

def test_base_document_with_no_documents
  SynapsePayRest::BaseDocument.create(test_base_document_args)
end
