require 'test_helper'

class DocumentTest < Minitest::Test
  def test_it_has_a_kyc
    kyc      = test_kyc_with_three_documents
    document = kyc.virtual_documents.first

    assert_kind_of SynapsePayRest::Kyc, document.kyc
  end

  def test_initialization_params_can_be_read
    args = {
      type: 'SSN',
      value: '1111-2222'
    }
    kyc      = test_kyc_with_three_documents
    document = SynapsePayRest::VirtualDocument.new(args)
    kyc.update(virtual_documents: [test_virtual_document])

    # check proper fields readable after update
    args.each { |arg, value| assert_equal document.send(arg), value }
  end

  def test_status_updated_on_submission
    kyc = SynapsePayRest::Kyc.create(test_kyc_base_info_with_three_documents)
    doc = kyc.virtual_documents.first

    refute_nil doc.status
    refute_nil doc.id
  end
end
