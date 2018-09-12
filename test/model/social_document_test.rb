require 'test_helper'

class SocialDocumentTest < Minitest::Test
  def test_email_2fa
    base_document_info = test_base_document_args
    email = 'test@test.com'
    email_doc = SynapsePayRest::SocialDocument.create(type: 'EMAIL_2FA', value: email)
    base_document_info[:social_documents] = [email_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)
    email_doc = base_document.social_documents.find {|d| d.type == 'EMAIL_2FA'}
    email_doc.verify_2fa(mfa_answer: '123456' , value: email)

    assert_equal 'SUBMITTED|REVIEWING', email_doc.status
  end

  def test_phone_number_2fa
    base_document_info = test_base_document_args
    phone_number = '4081231234'
    phone_number_doc = SynapsePayRest::SocialDocument.create(type: 'PHONE_NUMBER_2FA', value: phone_number)
    base_document_info[:social_documents] = [phone_number_doc]
    base_document = SynapsePayRest::BaseDocument.create(base_document_info)
    phone_number_doc = base_document.social_documents.find {|d| d.type == 'PHONE_NUMBER_2FA'}
    phone_number_doc.verify_2fa(mfa_answer: '123456' , value: phone_number)

    assert_equal 'SUBMITTED|REVIEWING', phone_number_doc.status
  end
end
