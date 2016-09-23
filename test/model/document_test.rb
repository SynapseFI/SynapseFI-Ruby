require 'test_helper'

class DocumentTest < Minitest::Test
  def test_it_has_a_cip_document
    cip = test_cip_document_with_documents
    document = test_cip_document_with_documents.virtual_documents.first

    assert_kind_of SynapsePayRest::CipDocument, document.cip_document
  end

  def test_initialization_params_can_be_read
    args = {
      type: 'SSN',
      value: '1111-2222'
    }
    cip_document = test_cip_document_with_documents
    document = SynapsePayRest::VirtualDocument.new(args)

    # check proper fields readable after update
    cip_document.update(virtual_documents: [document])
    args.each { |arg, value| assert_equal document.send(arg), value }
    assert_equal document.cip_document, cip_document
  end

  def test_status_updated_on_submission
    doc = test_social_document
    cip_info = {
      user: test_user,
      email: 'pru@pie.com',
      phone_number: '4444444',
      ip: '127002',
      name: 'Piper',
      alias: 'Hallowell',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 1,
      birth_month: 2,
      birth_year: 1933,
      address_street: '333 14th St',
      address_city: 'SF',
      address_subdivision: 'CA',
      address_postal_code: '94114',
      address_country_code: 'US',
      social_documents: [doc]
    }
    cip_doc = SynapsePayRest::CipDocument.create(cip_info)
    # binding.pry
    refute_nil doc.status
    refute_nil doc.id
  end
end
