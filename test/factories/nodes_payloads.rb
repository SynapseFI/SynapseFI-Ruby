def test_ach_us_login_no_mfa_payload
  {
    'type' => 'ACH-US',
    'info' => {
      'bank_id'   => 'synapse_nomfa',
      'bank_pw'   => 'test1234',
      'bank_name' => 'fake'
    }
  }
end

def test_ach_us_login_with_mfa_payload
  {
    'type' => 'ACH-US',
    'info' => {
      'bank_id' => 'synapse_good',
      'bank_pw' => 'test1234',
      'bank_name' => 'fake'
    }
  }
end

def test_mfa_payload(access_token:, mfa_answer: 'test_answer')
  {
    'access_token' => access_token,
    'mfa_answer'   => mfa_answer
  }
end

def test_ach_us_manual_payload(nickname: 'Ruby Library Test Savings Account',
                               name_on_account: Faker::Name.name,
                               account_num: Faker::Number.number(10).to_s,
                               routing_num: '051000017',
                               type: 'PERSONAL',
                               klass: 'CHECKING',
                               supp_id: Faker::Number.number(4).to_s)
  {
    'type' => 'ACH-US',
    'info' => {
      'nickname'        => nickname,
      'name_on_account' => name_on_account,
      'account_num'     => account_num,
      'routing_num'     => routing_num,
      'type'            => type,
      'class'           => klass
    },
    'extra' => {
      'supp_id' => supp_id
    }
  }
end

def test_microdeposit_payload(amounts: [0.1, 0.1])
  {'micro' => amounts}
end

def test_synapse_us_payload
  {
    'type' => 'SYNAPSE-US',
    'info' => {
      'nickname' => 'Synapse Account'
    }
  }
end

def test_deposit_us_payload
  {
    'type' => 'DEPOSIT-US',
    'info' => {
      'nickname' => 'Deposit Account'
    }
  }
end
