def test_ach_us_create_args(user: test_user,
                            nickname: 'Test ACH-US Account',
                            account_number: Faker::Number.number(10).to_s,
                            routing_number: '051000017',
                            account_type: 'PERSONAL',
                            account_class: 'CHECKING',
                            supp_id: Faker::Number.number(10).to_s)
  {
    user: user,
    nickname: nickname,
    account_number: account_number,
    routing_number: routing_number,
    account_type: account_type,
    account_class: account_class,
    supp_id: supp_id,
  }
end

def test_ach_us_create_via_login_args(user: test_user,
                                      bank_name: 'bofa',
                                      username: 'synapse_nomfa',
                                      password: 'test1234')
  {
    user: user,
    bank_name: bank_name,
    username: username,
    password: password
  }
end

def test_synapse_us_create_args(user: test_user,
                                nickname: 'Test Synapse-US Account',
                                supp_id: Faker::Number.number(10).to_s)
  {
    user: user,
    nickname: nickname,
    supp_id: supp_id
  }
end
