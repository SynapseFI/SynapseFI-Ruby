require 'test_helper'

class AtmTest < Minitest::Test
  def test_locate_atm_with_zip
    args = atm_args_zip
    atms = SynapsePayRest::Atm.locate(args)
    atm = atms[0]
    
    assert_instance_of SynapsePayRest::Atm, atm

    other_instance_vars = [:client, :address_city, :address_country, :address_postal_code, :address_state, :address_street,
                      :latitude, :longitude, :id, :isAvailable24Hours, :isDepositAvailable, :isHandicappedAccessible, :isOffPremise,
                      :isSeasonal, :locationDescription, :logoName, :name, :distance]

    other_instance_vars.each { |var| refute_nil atm.send(var) }
  end

  def test_locate_atm_with_lat_and_lon
    args = atm_args_lat_lon
    atms = SynapsePayRest::Atm.locate(args)
    atm = atms[0]
    
    assert_instance_of SynapsePayRest::Atm, atm

    other_instance_vars = [:client, :address_city, :address_country, :address_postal_code, :address_state, :address_street,
                      :latitude, :longitude, :id, :isAvailable24Hours, :isDepositAvailable, :isHandicappedAccessible, :isOffPremise,
                      :isSeasonal, :locationDescription, :logoName, :name, :distance]

    other_instance_vars.each { |var| refute_nil atm.send(var) }
  end
end
