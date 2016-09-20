module SynapsePayRest
  class Document
    # TODO: validate category, values, and type based on possible options (different based on whether created or fetched)
    attr_reader :email, :phone_number, :ip, :name, :alias, :entity_type,
                :entity_scope, :birth_day, :birth_month, :birth_year,
                :address_street, :address_city, :address_subdivision,
                :address_postal_code, :address_country_code, :category, :type,
                :value, :status, :id

    def initialize(**options)
      params_to_instance_variables(options)
    end

    private

    def params_to_instance_variables(params_hash)
      params_hash.each do |param, value|
        instance_variable_set("@#{param}", value)
      end
    end
  end
end
