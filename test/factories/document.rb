def test_physical_document
  SynapsePayRest::PhysicalDocument.create(
    type: 'GOVT_ID',
    file_path: fixture_path('id.png')
  )
end

def test_social_document
  SynapsePayRest::SocialDocument.create(
    type: 'FACEBOOK',
    value: 'facebook.com/mctesterson'
  )
end

def test_virtual_document
  SynapsePayRest::VirtualDocument.create(
    type: 'SSN',
    value: '2222'
  )
end
