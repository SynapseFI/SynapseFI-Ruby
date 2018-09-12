def test_ach_us_create_args(user: test_user,
                            nickname: 'Test ACH-US Account',
                            account_number: Faker::Number.number(10).to_s,
                            routing_number: '051000017',
                            account_type: 'PERSONAL',
                            account_class: 'CHECKING',
                            supp_id: Faker::Number.number(10).to_s,
                            gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    account_number: account_number,
    routing_number: routing_number,
    account_type: account_type,
    account_class: account_class,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_ach_us_create_via_bank_login_args(user: test_user,
                                           bank_name: 'fake',
                                           username: 'synapse_nomfa',
                                           password: 'test1234')
  {
    user: user,
    bank_name: bank_name,
    username: username,
    password: password
  }
end

def test_ach_us_create_via_bank_login_mfa_args(user: test_user,
                                           access_token: 'fake')
  {
    user: user,
    access_token: access_token
  }
end

def test_eft_ind_create_args(user: test_user,
                             nickname: 'Test EFT-IND Account',
                             ifsc: 'BKID0005046',
                             account_number: Faker::Number.number(10).to_s,
                             supp_id: Faker::Number.number(10).to_s,
                             gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    ifsc: ifsc,
    account_number: account_number,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_eft_np_create_args(user: test_user,
                            nickname: 'Test EFT-NP Account',
                            bank_name: 'Siddhartha Bank',
                            account_number: Faker::Number.number(10).to_s,
                            supp_id: Faker::Number.number(10).to_s,
                            gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    bank_name: bank_name,
    account_number: account_number,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_iou_create_args(user: test_user,
                         nickname: 'Test IOU Node',
                         currency: 'USD',
                         supp_id: Faker::Number.number(10).to_s,
                         gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    currency: currency,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_reserve_us_create_args(user: test_user,
                                nickname: 'Test RESERVE-US Account',
                                supp_id: Faker::Number.number(10).to_s,
                                gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_synapse_ind_create_args(user: test_user,
                                 nickname: 'Test SYNAPSE-IND Account',
                                 supp_id: Faker::Number.number(10).to_s,
                                 gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_synapse_np_create_args(user: test_user,
                                nickname: 'Test SYNAPSE-NP Account',
                                supp_id: Faker::Number.number(10).to_s,
                                gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_synapse_us_create_args(user: test_user,
                                nickname: 'Test SYNAPSE-US Account',
                                supp_id: Faker::Number.number(10).to_s,
                                gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_subaccount_us_create_args(user: test_user,
                                           nickname: 'Test SUBACCOUNT-US Account',
                                           supp_id: Faker::Number.number(10).to_s,
                                           gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_triumph_subaccount_us_create_args(user: test_user,
                                           nickname: 'Test TRIUMPH-SUBACCOUNT-US Account',
                                           supp_id: Faker::Number.number(10).to_s,
                                           gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_wire_int_create_args(user: test_user,
                              nickname: 'Test WIRE-INT Account',
                              bank_name: 'Bank of America',
                              account_number: Faker::Number.number(10).to_s,
                              routing_number: '022300173',
                              name_on_account: user.legal_names.first,
                              address: Faker::Address.street_address,
                              correspondent_routing_number: '022300173',
                              correspondent_bank_name: 'Bank of America',
                              correspondent_address: Faker::Address.street_address,
                              correspondent_swift: 'TSIGFR22',
                              swift: 'TSIGFR22',
                              supp_id: Faker::Number.number(10).to_s,
                              gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    bank_name: bank_name,
    account_number: account_number,
    routing_number: routing_number,
    name_on_account: name_on_account,
    address: address,
    correspondent_routing_number: correspondent_routing_number,
    correspondent_bank_name: correspondent_bank_name,
    correspondent_address: correspondent_address,
    swift: swift,
    correspondent_swift: correspondent_swift,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted,
  }
end

def test_wire_us_create_args(user: test_user,
                             nickname: 'Test WIRE-US Account',
                             account_number: Faker::Number.number(10).to_s,
                             routing_number: '026009593',
                             name_on_account: user.legal_names.first,
                             bank_name: 'Bank of America',
                             correspondent_routing_number: '026009593',
                             correspondent_bank_name: 'Bank of America',
                             correspondent_address: Faker::Address.street_address,
                             supp_id: Faker::Number.number(10).to_s,
                             gateway_restricted: nil)
  {
    user: user,
    nickname: nickname,
    account_number: account_number,
    routing_number: routing_number,
    name_on_account: name_on_account,
    correspondent_routing_number: correspondent_routing_number,
    correspondent_bank_name: correspondent_bank_name,
    correspondent_address: correspondent_address,
    supp_id: supp_id,
    gateway_restricted: gateway_restricted
  }
end

def test_check_us_create_args(user: test_user,
                             type: 'CHECK-US', 
                             nickname: 'Test CHECK-US Account',
                             payee_name: 'Test McTest',
                             address_street: "1 MARKET ST",
                             address_city: "SAN FRANCISCO",
                             address_subdivision: "CA",
                             address_country_code: "US",
                             address_postal_code:  "94105" 
                             )
  {
  user: user,
  type: type,
  nickname: nickname,
  payee_name: payee_name,
  address_street: address_street,
  address_city: address_city,
  address_subdivision: address_subdivision,
  address_country_code: address_country_code,
  address_postal_code:    address_postal_code
}
end

def test_ib_deposit_us_create_args(user: test_user,
                                type: 'IB-DEPOSIT-US',
                                nickname: 'Test IB-DEPOSIT-US Account'
                                )
  {
    user: user,
    type: type,
    nickname: nickname
  }
end

def test_ib_subaccount_us_create_args(user: test_user,
                                type: 'IB-SUBACCOUNT-US',
                                nickname: 'Test IB-SUBACCOUNT-US Account'
                                )
  {
    user: user,
    type: type,
    nickname: nickname
  }
end

def test_clearing_us_create_args(user: test_user,
                                type: 'CLEARING-US',
                                nickname: 'Test CLEARING-US Account'
                                )
  {
    user: user,
    type: type,
    nickname: nickname
  }
end

def test_deposit_us_create_args(user: test_user,
                                type: 'DEPOSIT-US',
                                nickname: 'Test DEPOSIT-US Account'
                                )
  {
    user: user,
    type: type,
    nickname: nickname
  }
end

def test_crypto_us_create_args(user: test_user,
                                type: 'CRYPTO-US',
                                nickname: 'Test CRYPTO-US Account'
                                )
  {
    user: user,
    type: type,
    nickname: nickname
  }
end

def test_ach_us_node(user: test_user)
  user.create_ach_us_node(test_ach_us_create_args(user: user))
end

def test_two_ach_us_nodes(user: test_user)
  args = test_ach_us_create_via_bank_login_args(user: user)
  user.create_ach_nodes_via_bank_login(args)
end

def test_synapse_us_node(user: test_user)
  args = test_synapse_us_create_args(user: user)
  user.create_synapse_us_node(args)
end

def test_wire_int_node(user: test_user)
  args = test_wire_int_node_create_args(user: user)
  user.create_wire_int_node(args)
end

def test_wire_us_node(user: test_user)
  args = test_wire_us_node_create_args(user: user)
  user.create_wire_us_node(args)
end

def test_check_us_node(user: test_user)
  args = test_check_us_create_args(user: user)
  user.create_check_us_node(args)
end

def test_crypto_us_node(user: test_user)
  args = test_crypto_us_create_args(user: user)
  user.create_crypto_us_node(args)
end

