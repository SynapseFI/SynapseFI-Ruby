# create different number of users for different tests
def test_transaction_payload(from_id:,
                             from_type:,
                             to_id:,
                             to_type:,
                             amount: rand(1..10),
                             currency: 'USD',
                             ip: '197.0.0.1')
  {
    'to' => {
      'type' => to_type,
      'id'   => to_id
    },
    'amount' => {
      'amount'   => amount,
      'currency' => currency
    },
    'extra' => {
      'ip' => ip
    }
  }
end
