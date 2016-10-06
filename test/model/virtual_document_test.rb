require 'test_helper'

class VirtualDocumentTest < Minitest::Test
  def test_ssn_failed
    ssn = '1111'
    base_document_info = test_base_document_args
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    base_document_info[:virtual_documents] = [ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)

    assert_equal 'SUBMITTED|INVALID', ssn_doc.status
    assert_empty ssn_doc.question_set
  end

  def test_ssn_successful
    ssn = '2222'
    base_document_info = test_base_document_args
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    base_document_info[:virtual_documents] = [ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)

    assert_equal 'SUBMITTED|VALID', ssn_doc.status
    assert_empty ssn_doc.question_set
  end

  def test_ssn_partially_successful_with_kba_and_correct_answers
    ssn = '3333'
    base_document_info = test_base_document_args
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    base_document_info[:virtual_documents] = [ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)

    assert_equal 'SUBMITTED|MFA_PENDING', ssn_doc.status
    refute_empty ssn_doc.question_set
    assert_instance_of SynapsePayRest::Question, ssn_doc.question_set.first

    # answer questions
    ssn_doc.question_set.each { |question| question.choice = 1 }
    ssn_doc.submit_kba

    assert_equal 'SUBMITTED|VALID', ssn_doc.status
  end

  def test_ssn_partially_successful_with_kba_and_incorrect_answers
    ssn = '3333'
    base_document_info = test_base_document_args
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    base_document_info[:virtual_documents] = [ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)

    assert_equal 'SUBMITTED|MFA_PENDING', ssn_doc.status
    refute_empty ssn_doc.question_set
    assert_instance_of SynapsePayRest::Question, ssn_doc.question_set.first

    # answer questions
    ssn_doc.question_set.each { |question| question.choice = 5 }
    ssn_doc.submit_kba

    assert_equal 'SUBMITTED|INVALID', ssn_doc.status
  end

  def test_updating_existing_ssn_doc
    bad_ssn = '1111'
    base_document_info = test_base_document_args
    bad_ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: bad_ssn)
    base_document_info[:virtual_documents] = [bad_ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)

    assert_equal 'SUBMITTED|INVALID', bad_ssn_doc.status

    # good ssn info
    good_ssn = '2222'
    good_ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: good_ssn)
    base_document.update(virtual_documents: [good_ssn_doc])

    assert_equal 'SUBMITTED|VALID', good_ssn_doc.status
    assert base_document.virtual_documents.any? { |vd| vd.status == 'SUBMITTED|VALID' }

    # verify in api
    response = test_client.users.get(user_id: base_document.user.id)
    assert response['documents'].last['virtual_docs'].any? do |vd|
      vd['status'] == 'SUBMITTED|VALID'
    end
  end
end
