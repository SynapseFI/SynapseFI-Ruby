require 'test_helper'

class InstitutionsTest < Minitest::Test
  def setup
    test_values   = test_client_with_instutitions
    @client       = test_values[:client]
  end

  def test_institutions_get
    institutions_response = @client.institutions.get()
    assert_equal '0', institutions_response['error_code']
    assert_equal '200', institutions_response['http_code']
  end

end
