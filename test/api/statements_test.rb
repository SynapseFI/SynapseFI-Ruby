require 'test_helper'

class StatementsTest < Minitest::Test
  def setup
    test_values   = test_client_with_statements
    @client       = test_values[:client]
  end

  def test_statements_get
    statements_response = @client.statements.get()
    assert_equal '0', statements_response['error_code']
    assert_equal '200', statements_response['http_code']
  end

end
