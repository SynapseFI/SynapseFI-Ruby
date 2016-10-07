require 'test_helper'

class BaseDocumentTest < Minitest::Test
  def test_initialize_params_can_be_read
    args = test_base_document_args_with_three_documents
    base_document = SynapsePayRest::BaseDocument.create(args)

    args.each do |arg, value|
      assert_equal base_document.send(arg), value
    end
  end

  def test_initialize_with_documents_adds_them_to_documents_array
    base_document = SynapsePayRest::BaseDocument.create(test_base_document_args_with_three_documents)
    physical_doc = base_document.physical_documents.first
    social_doc   = base_document.social_documents.first
    virtual_doc  = base_document.virtual_documents.first

    # verify docs belonging to User object
    assert_equal base_document.physical_documents.length, 1
    assert_equal base_document.social_documents.length, 1
    assert_equal base_document.virtual_documents.length, 1
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
    social_doc_original_value = social_doc.value
    original_email = base_document.email

    response_before_update = test_client.users.get(user_id: user.id)
    response_before_update_facebook = response_before_update['documents'].first['social_docs'].select do |doc|
      doc['document_type'] == 'FACEBOOK'
    end

    # change value
    social_doc.value = 'facebook.com/spoopy'
    things_to_update = {
      email: 'judytrudy@boopy.com',
      social_documents: [social_doc]
    }

    base_document.update(things_to_update)
    new_email = base_document.email

    # verify changed in instance
    refute_equal original_email, new_email
    refute_equal social_doc.value, social_doc_original_value

    # verify doc updated in API
    response_after_update = test_client.users.get(user_id: user.id)
    response_after_update_facebook = response_after_update['documents'].first['social_docs'].select { |doc| doc['document_type'] == 'FACEBOOK' }
    response_after_update_phone_number = response_after_update_facebook.find { |ph| ph['id'] == social_doc.id }

    # id should match id in response
    assert_equal response_after_update['documents'].first['id'], base_document.id
    # see that updated times have changed
    before_checksum = response_before_update_facebook.map {|ph| ph['last_updated']}.reduce(:+)
    after_checksum = response_after_update_facebook.map {|ph| ph['last_updated']}.reduce(:+)
    assert_operator after_checksum, :>, before_checksum
    # verify status and id updated

    assert_equal response_after_update_phone_number['status'], social_doc.status

    # @todo test last updated changes on virtual/physical docs
  end

  def test_add_physical_documents
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.physical_documents

    physical_doc = test_physical_document
    base_doc.add_physical_documents([physical_doc])
    assert_includes base_doc.physical_documents, physical_doc

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['physical_docs'].any? {|d| d['document_type'] == 'GOVT_ID'}
  end

  def test_add_social_documents
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.social_documents

    social_doc = test_social_document
    base_doc.add_social_documents([social_doc])
    assert_includes base_doc.social_documents, social_doc

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['social_docs'].any? {|d| d['document_type'] == 'FACEBOOK'}
  end

  def test_add_virtual_documents
    base_doc = test_base_document_with_no_documents
    assert_empty base_doc.virtual_documents

    virtual_doc = test_virtual_document
    base_doc.add_virtual_documents([virtual_doc])
    assert_includes base_doc.virtual_documents, virtual_doc

    # verify added in api
    response = test_client.users.get(user_id: base_doc.user.id)
    assert response['documents'].first['virtual_docs'].any? {|d| d['document_type'] == 'SSN'}
  end
end
