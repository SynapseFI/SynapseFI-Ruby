require 'test_helper'

class DocumentTest < Minitest::Test
  def test_initialization_params_can_be_read
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
      address_country_code: 'SP',
      category: :virtual,
      type: 'SSN',
      value: '2222'
    }
    document = SynapsePayRest::Document.new(args)

    args.each do |arg, value|
      assert_equal document.send(arg), value
    end
  end
end
