require 'test_helper'

class QuestionTest < Minitest::Test
  def test_invalid_answer_choice_given
    skip 'deprecated'
    ssn = '3333'
    base_document_info = test_base_document_args
    ssn_doc = SynapsePayRest::VirtualDocument.create(type: 'SSN', value: ssn)
    base_document_info[:virtual_documents] = [ssn_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)
    ssn_doc = base_document.virtual_documents.find { |d| d.type == ssn_doc.type }

    assert_equal 'SUBMITTED|MFA_PENDING', ssn_doc.status
    refute_empty ssn_doc.question_set

    question = ssn_doc.question_set.first
    assert_instance_of SynapsePayRest::Question, question

    assert_raises(ArgumentError) { question.choice = 10 }
    ssn_doc = ssn_doc.submit_kba
    assert_equal 'SUBMITTED|INVALID', ssn_doc.status
  end
end
