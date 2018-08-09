require 'test_helper'

class InstitutionTest < Minitest::Test
  def setup
    @options = {
      client_id:        ENV.fetch('TEST_CLIENT_ID'),
      client_secret:    ENV.fetch('TEST_CLIENT_SECRET'),
      ip_address:       '127.0.0.1',
      fingerprint:      'test_fp',
      development_mode: true
    } 
  end

  def test_institutions_all
    client = SynapsePayRest::Client.new(@options)
    institutions = SynapsePayRest::Institution.all(client: client)
    institution = institutions[0]
    
    assert_instance_of SynapsePayRest::Institution, institution

    other_instance_vars = [:client, :bank_code, :bank_name, :features, :forgotten_password, :is_active, :logo, :tx_history_months]

    other_instance_vars.each { |var| refute_nil institution.send(var) }
  end
end
