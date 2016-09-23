require 'test_helper'

class VirtualDocumentTest < Minitest::Test
  def test_ssn_failed
    ssn = '1111'
    cip_info = test_cip_document_info
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    cip_info[:virtual_documents] = [ssn_doc]
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)

    assert_equal 'SUBMITTED|INVALID', ssn_doc.status
  end

  def test_ssn_successful
    ssn = '2222'
    cip_info = test_cip_document_info
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    cip_info[:virtual_documents] = [ssn_doc]
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)

    assert_equal 'SUBMITTED|VALID', ssn_doc.status
  end

  def test_ssn_partially_successful_with_kba
    ssn = '3333'
    cip_info = test_cip_document_info
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    cip_info[:virtual_documents] = [ssn_doc]
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)

    assert_equal 'SUBMITTED|MFA_PENDING', ssn_doc.status
  end
end
