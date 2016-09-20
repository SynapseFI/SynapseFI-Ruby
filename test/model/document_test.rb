require 'test_helper'

class DocumentTest < Minitest::Test
  def test_initialization_params_can_be_accessed_via_reader
    args = {
      email: '123@abc.org',
      phone_number: '951235',
      ip: '127001',
      name: 'Hilda',
      alias: 'Olga',
      entity_type: 'F',
      entity_scope: 'Arts & Entertainment',
      birth_day: 9,
      birth_month: 19,
      birth_year: 1942,
      address_street: '123 Hummingbird Way',
      address_city: 'Madrid',
      address_subdivision: 'Madrid Area',
      address_postal_code: '12000',
      address_country_code: 'SP'
    }

    document = SynapsePayRest::Document.new(args)
    assert_equal document.email, args[:email]
    assert_equal document.birth_year, args[:birth_year]
  end
end
