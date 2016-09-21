require 'test_helper'

class CipDocumentTest < Minitest::Test
  def setup
    @cip_doc = test_cip_document_with_documents
  end

  def test_initialization_params_can_be_read
    args = {
      user: test_user,
      email: 'piper@pie.com',
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
      address_country_code: 'US'
    }
    cip_doc = SynapsePayRest::CipDocument.new(args)

    args.each do |arg, value|
      assert_equal cip_doc.send(arg), value
    end
  end

  def test_add_documents_pushes_documents_to_documents_array
    cip_info = {
      user: test_user,
      email: 'piper@pie.com',
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
      address_country_code: 'US'
    }
    social_doc_info = {
      category: :social,
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
      category: :virtual,
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
      category: :physical,
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    cip_doc      = SynapsePayRest::CipDocument.new(cip_info)
    social_doc   = SynapsePayRest::Document.new(social_doc_info)
    virtual_doc  = SynapsePayRest::Document.new(virtual_doc_info)
    physical_doc = SynapsePayRest::Document.new(physical_doc_info)
    cip_doc.add_documents(virtual_doc, physical_doc, social_doc)

    # verify docs associated with User object
    assert_includes cip_doc.documents, social_doc
    assert_includes cip_doc.documents, virtual_doc
    assert_includes cip_doc.documents, physical_doc
  end

  def test_submit
    cip_info = {
      user: test_user,
      email: 'piper@pie.com',
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
      address_country_code: 'US'
    }
    social_doc_info = {
      category: :social,
      type: 'FACEBOOK',
      value: 'https://www.facebook.com/mariachi'
    }
    virtual_doc_info = {
      category: :virtual,
      type: 'SSN',
      value: '2222'
    }
    physical_doc_info = {
      category: :physical,
      type: 'GOVT_ID',
      value: 'data:text/csv;base64,SUQs=='
    }
    cip_doc      = SynapsePayRest::CipDocument.new(cip_info)
    social_doc   = SynapsePayRest::Document.new(social_doc_info)
    virtual_doc  = SynapsePayRest::Document.new(virtual_doc_info)
    physical_doc = SynapsePayRest::Document.new(physical_doc_info)
    cip_doc.add_documents(virtual_doc, physical_doc, social_doc)
    cip_doc.submit

    # # verify with API that documents were added
    response_docs = test_client.users.get(user_id: cip_doc.user.id)['documents']
    assert [social_doc.cip_document.id, virtual_doc.cip_document.id, physical_doc.cip_document.id].all? do |id|
      id == response_docs['_id']
    end
    assert response_docs.first['social_docs'].any? { |doc| doc['document_type'] == social_doc.type }
    assert response_docs.first['virtual_docs'].any? { |doc| doc['document_type'] == virtual_doc.type }
    assert response_docs.first['physical_docs'].any? { |doc| doc['document_type'] == physical_doc.type }
  end
end
