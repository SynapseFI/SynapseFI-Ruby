def test_subnet_create_args(	 node:,
                                 nickname: 'Subnet Test')
  {
    node: node,
    nickname: nickname,
  }
end
def test_subnet(node:, nickname:, **options)
    args = test_subnet_create_args(node: node, nickname: nickname, **options)
    SynapsePayRest::Subnet.create(args)
end
