def test_transaction_create_args(node:,
                                 to_type:,
                                 to_id:,
                                 amount: rand(5.00..20.00).round(2),
                                 currency: 'USD',
                                 supp_id: Faker::Number.number(10).to_s,
                                 note: Faker::Hipster.sentence(3),
                                 process_in: 1,
                                 ip: '127.0.0.1',
                                 fee_amount: rand(1.00..2.00).round(2),
                                 fee_note: 'Facilitator Fee',
                                 fee_to_id: to_id)
  {
    node: node,
    to_type: to_type,
    to_id: to_id,
    amount: amount,
    currency: currency,
    supp_id: supp_id,
    note: note,
    process_in: process_in,
    ip: ip,
    fee_amount: fee_amount,
    fee_note: fee_note,
    fee_to_id: fee_to_id
  }
end
