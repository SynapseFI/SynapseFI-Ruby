require 'test_helper'

class ErrorTest < Minitest::Test
  def test_400_error_code
    response = {"error"=>{"en"=>"Unable to verify document information. Please submit a valid copy of passport/driver's license."}, "error_code"=>"400", "http_code"=>"409", "success"=>false}

    error = SynapsePayRest::Error.error_from_response(response, 409)

    assert_instance_of SynapsePayRest::Error::Conflict, error
    assert_kind_of SynapsePayRest::Error::ClientError, error
    assert_equal "Unable to verify document information. Please submit a valid copy of passport/driver's license.", error.message
    assert_equal '400', error.code
    assert_equal response, error.response
  end

  def test_404_error_code_with_real_request
    nonexistent_user_id = '11111111111111'

    assert_raises SynapsePayRest::Error::NotFound do
      test_client.users.get(user_id: nonexistent_user_id)
    end
  end
end
