require 'test_helper'

class DocumentTest < Minitest::Test
  def setup
    @document = test_document
  end

  def test_it_has_a_cip_document
    cip = test_cip_document_with_documents
    document = test_cip_document_with_documents.documents.first

    assert_instance_of SynapsePayRest::CipDocument, document
  end

  def test_initialization_params_can_be_read
    args = {
      category: :virtual,
      type: 'SSN',
      value: '2222',
      cip_document_id: '1'
    }
    document = SynapsePayRest::Document.new(args)

    args.each do |arg, value|
      assert_equal document.send(arg), value
    end
  end
end
