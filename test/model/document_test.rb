require 'test_helper'

class DocumentTest < Minitest::Test
  def test_it_has_a_base_document
    base_document = test_base_document_with_three_documents
    document = base_document.virtual_documents.first

    assert_kind_of SynapsePayRest::BaseDocument, document.base_document
  end

  def test_initialization_params_can_be_read
    args = {
      type: 'SSN',
      value: '1111-2222'
    }
    base_document = test_base_document_with_three_documents
    document = SynapsePayRest::VirtualDocument.new(args)
    base_document.update(virtual_documents: [test_virtual_document])

    # check proper fields readable after update
    args.each { |arg, value| assert_equal document.send(arg), value }
  end

  def test_status_updated_on_submission
    base_document = SynapsePayRest::BaseDocument.create(test_base_document_args_with_three_documents)
    doc = base_document.virtual_documents.first

    refute_nil doc.status
    refute_nil doc.id
  end
end
