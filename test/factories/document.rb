def test_physical_document
  SynapsePayRest::PhysicalDocument.create(
    type: 'GOVT_ID',
    value: fixture_path('id.png')
  )
end

def test_social_document
  SynapsePayRest::SocialDocument.create(
    type: 'PHONE_NUMBER',
    value: '415-555-5555'
  )
end

def test_virtual_document
  SynapsePayRest::VirtualDocument.create(
    type: 'SSN',
    value: '2222'
  )
end
