require 'test_helper'

class BaseDocumentTest < Minitest::Test
  def test_attrs_can_be_read
    args = test_base_document_args_with_three_documents
    base_document = SynapsePayRest::BaseDocument.create(args)

    attrs = [:user, :id, :permission_scope]

    attrs.each { |attr| refute_nil base_document.send(attr) }
  end

  def test_initialize_with_documents_adds_them_to_documents_array
    base_document = SynapsePayRest::BaseDocument.create(test_base_document_args_with_three_documents)
    physical_doc = base_document.physical_documents.first
    social_doc   = base_document.social_documents.first
    virtual_doc  = base_document.virtual_documents.first

    # verify docs belonging to User object
    refute_empty base_document.physical_documents
    refute_empty base_document.social_documents
    refute_empty base_document.virtual_documents
    assert_includes base_document.social_documents, social_doc
    assert_includes base_document.virtual_documents, virtual_doc
    assert_includes base_document.physical_documents, physical_doc
  end

  def test_submit
    base_document = SynapsePayRest::BaseDocument.create(test_base_document_args_with_three_documents)
    physical_doc = base_document.physical_documents.first
    social_doc   = base_document.social_documents.first
    virtual_doc  = base_document.virtual_documents.first

    refute_nil base_document.id
    # verify with API that documents were added
    response_docs = test_client.users.get(user_id: base_document.user.id)['documents']
    assert [social_doc.base_document.id, virtual_doc.base_document.id,
            physical_doc.base_document.id].all? do |id|
      id == response_docs['_id']
    end
    assert response_docs.first['social_docs'].any? { |doc| doc['document_type'] == social_doc.type }
    assert response_docs.first['virtual_docs'].any? { |doc| doc['document_type'] == virtual_doc.type }
    assert response_docs.first['physical_docs'].any? { |doc| doc['document_type'] == physical_doc.type }
  end

  def test_update
    user = test_user_with_base_document_with_three_documents
    base_document = user.base_documents.first
    social_doc = base_document.social_documents.find { |doc| doc.type == 'FACEBOOK' }

    # change value
    social_doc.value = 'facebook.com/spoopy'
    things_to_update = {
      entity_scope: 'Lawyer',
      social_documents: [social_doc]
    }

    base_document = base_document.update(things_to_update)

    # verify doc status and id match between api and doc instances
    response_after_update = test_client.users.get(user_id: user.id)
    response_physical_docs = response_after_update['documents'].first['physical_docs']
    response_social_docs = response_after_update['documents'].first['social_docs']
    response_virtual_docs = response_after_update['documents'].first['virtual_docs']

    response_physical_docs.each do |doc|
      assert base_document.physical_documents.any? { |pd| pd.id == doc['id'] && pd.status == doc['status'] }
    end
    response_social_docs.each do |doc|
      assert base_document.social_documents.any? { |sd| sd.id == doc['id'] && sd.status == doc['status'] }
    end
    response_virtual_docs.each do |doc|
      assert base_document.virtual_documents.any? { |vd| vd.id == doc['id'] && vd.status == doc['status'] }
    end

    # id should match id in response
    assert_equal response_after_update['documents'].first['id'], base_document.id

    # @todo test last updated changes on virtual/physical docs
  end

  def test_add_physical_document
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.physical_documents

    physical_doc = test_physical_document
    base_doc = base_doc.add_physical_documents(physical_doc)
    assert base_doc.physical_documents.any? { |d| d.type == physical_doc.type }

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['physical_docs'].any? {|d| d['document_type'] == 'GOVT_ID'}
  end

  def test_add_social_document
    base_doc = test_base_document_with_no_documents

    social_doc = test_social_document
    base_doc = base_doc.add_social_documents(social_doc)
    assert base_doc.social_documents.any? { |d| d.type == social_doc.type }

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['social_docs'].any? {|d| d['document_type'] == 'FACEBOOK'}
  end

  def test_add_virtual_document
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.virtual_documents

    virtual_doc = test_virtual_document
    base_doc = base_doc.add_virtual_documents(virtual_doc)
    assert base_doc.virtual_documents.any? { |d| d.type == virtual_doc.type }

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['virtual_docs'].any? {|d| d['document_type'] == 'SSN'}
  end

  def test_add_physical_documents
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.physical_documents

    physical_doc = test_physical_document
    physical_doc2 = physical_doc.dup
    physical_doc2.type = 'SELFIE'
    base_doc = base_doc.add_physical_documents(physical_doc, physical_doc2)

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['physical_docs'].any? {|d| d['document_type'] == physical_doc.type}
    assert response['documents'].first['physical_docs'].any? {|d| d['document_type'] == physical_doc2.type}
  end

  def test_add_social_documents
    base_doc = test_base_document_with_no_documents

    social_doc = test_social_document
    social_doc2 = social_doc.dup
    social_doc2.type = 'TWITTER'
    base_doc = base_doc.add_social_documents(social_doc, social_doc2)

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['social_docs'].any? {|d| d['document_type'] == social_doc.type}
    assert response['documents'].first['social_docs'].any? {|d| d['document_type'] == social_doc2.type}
  end

  def test_add_virtual_documents
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.virtual_documents

    virtual_doc = test_virtual_document
    virtual_doc2 = virtual_doc.dup
    virtual_doc2.type = 'PASSPORT'
    base_doc = base_doc.add_virtual_documents(virtual_doc, virtual_doc2)

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['virtual_docs'].any? {|d| d['document_type'] == virtual_doc.type}
    assert response['documents'].first['virtual_docs'].any? {|d| d['document_type'] == virtual_doc2.type}
  end
end
