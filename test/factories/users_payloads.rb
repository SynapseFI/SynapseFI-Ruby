def test_users_create_payload(email: Faker::Internet.email,
                              password: Faker::Internet.password,
                              read_only: false,
                              phone_number: Faker::PhoneNumber.phone_number,
                              legal_name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
                              note: Faker::Hipster.sentence(3),
                              supp_id: Faker::Number.number(10).to_s,
                              is_business: false)
  {
    'logins' => [
      {
        'email'     => email,
        'password'  => password,
        'read_only' => read_only
      }
    ],
    'phone_numbers' => [
      phone_number
    ],
    'legal_names' => [
      legal_name
    ],
    'extra' => {
      'note'        => note,
      'supp_id'     => supp_id,
      'is_business' => is_business
    }
  }
end

def test_users_update_payload(refresh_token:,
                              email: Faker::Internet.email,
                              password: Faker::Internet.password,
                              read_only: false,
                              phone_number: Faker::PhoneNumber.phone_number,
                              legal_name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
                              remove_phone_number: '123456')
  {
    'refresh_token' => refresh_token,
    'update' => {
      'login' => {
        'email'     => email,
        'password'  => password,
        'read_only' => read_only
      },
      'phone_number'        => phone_number,
      'legal_name'          => legal_name,
      'remove_phone_number' => remove_phone_number
    }
  }
end

def test_document_hash(value:, type:)
  {
    'document_value' => value,
    'document_type'  => type
  }
end

def test_valid_ssn_hash
  test_document_hash(value: '111-111-2222', type: 'SSN')
end

def test_kba_ssn_hash
  test_document_hash(value: '111-111-3333', type: 'SSN')
end

def test_invalid_ssn_hash
  test_document_hash(value: '111-111-1111', type: 'SSN')
end

def test_facebook_hash
  test_document_hash(
    value: "https://www.facebook.com/#{Faker::Internet.user_name}",
    type: 'FACEBOOK'
  )
end

def test_govt_id_hash
  test_document_hash(value: test_base64_image, type: 'GOVT_ID')
end

def test_add_doc_kyc1_payload(birth_day: rand(1..28),
                                   birth_month: rand(1..12),
                                   birth_year: rand(1930..1996),
                                   name_first: Faker::Name.first_name,
                                   name_last: Faker::Name.last_name,
                                   address_street1: Faker::Address.street_address,
                                   address_postal_code: Faker::Address.zip,
                                   address_country_code: 'US',
                                   document_value: '2222',
                                   document_type: 'SSN')
  {
    'doc' => {
      'birth_day'            => birth_day,
      'birth_month'          => birth_month,
      'birth_year'           => birth_year,
      'name_first'           => name_first,
      'name_last'            => name_last,
      'address_street1'      => address_street1,
      'address_postal_code'  => address_postal_code,
      'address_country_code' => address_country_code,
      'document_value'       => document_value,
      'document_type'        => document_type
    }
  }
end

def test_kba_kyc1_payload(question_set_id:,
                          answers: [
                            { 'question_id' =>  1, 'answer_id' => 1 },
                            { 'question_id' =>  2, 'answer_id' => 1 },
                            { 'question_id' =>  3, 'answer_id' => 1 },
                            { 'question_id' =>  4, 'answer_id' => 1 },
                            { 'question_id' =>  5, 'answer_id' => 2 }
                          ])
  {
    'doc' => {
      'question_set_id' => question_set_id,
      'answers' => answers
    }
  }
end

def test_add_documents_kyc2_payload(email: Faker::Internet.email,
                                    phone_number: Faker::PhoneNumber.phone_number,
                                    ip: '127.0.0.1',
                                    name: Faker::Name.first_name + ' ' + Faker::Name.last_name,
                                    aka: Faker::Name.name,
                                    entity_type: %w(M F).sample,
                                    entity_scope: 'Arts & Entertainment',
                                    day: rand(1..28),
                                    month: rand(1..12),
                                    year: rand(1930..1996),
                                    address_street: Faker::Address.street_name,
                                    address_city: Faker::Address.city,
                                    address_subdivision: Faker::Address.state_abbr,
                                    address_postal_code: Faker::Address.zip,
                                    address_country_code: Faker::Address.country_code,
                                    physical_docs: [test_govt_id_hash],
                                    social_docs: [test_facebook_hash],
                                    virtual_docs: [test_valid_ssn_hash]
                                   )
  {
    'documents' => [{
      'email'                => email,
      'phone_number'         => phone_number,
      'ip'                   => ip,
      'name'                 => name,
      'alias'                => aka,
      'entity_type'          => entity_type,
      'entity_scope'         => entity_scope,
      'day'                  => day,
      'month'                => month,
      'year'                 => year,
      'address_street'       => address_street,
      'address_city'         => address_city,
      'address_subdivision'  => address_subdivision,
      'address_postal_code'  => address_postal_code,
      'address_country_code' => address_country_code,
      'virtual_docs'         => virtual_docs,
      'physical_docs'        => physical_docs,
      'social_docs'          => social_docs
    }]
  }
end

def test_kba_kyc_2_payload(base_document_id:,
                           document_id:,
                           answers: [
                            { 'question_id' => 1, 'answer_id' => 1 },
                            { 'question_id' => 2, 'answer_id' => 1 },
                            { 'question_id' => 3, 'answer_id' => 1 },
                            { 'question_id' => 4, 'answer_id' => 1 },
                            { 'question_id' => 5, 'answer_id' => 1 }
                          ])
  {
    'documents' => [{
      'id' => base_document_id,
      'virtual_docs' => [{
        'id' => document_id,
        'meta' => {
          'question_set' => {
            'answers' => [
              { 'question_id' => 1, 'answer_id' => 1 },
              { 'question_id' => 2, 'answer_id' => 1 },
              { 'question_id' => 3, 'answer_id' => 1 },
              { 'question_id' => 4, 'answer_id' => 1 },
              { 'question_id' => 5, 'answer_id' => 1 }
            ]
          }
        }
      }]
    }]
  }
end

def test_base64_image
  'data:image/png;base64,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'
end
