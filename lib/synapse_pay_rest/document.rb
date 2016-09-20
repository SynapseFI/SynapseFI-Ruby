module SynapsePayRest
  class Document
    def initialize(email:, phone_number:, ip:, name:, alias:, entity_type:, 
      entity_scope:, birth_day:, birth_month:, birth_year:, address_street:, 
      address_city:, address_subdivision:, address_postal_code:, address_country_code:, **options)
      params = method(__method__).parameters
      values = params.map { |param| binding.local_variable_get(param[1].to_s)}
      params_to_attr_accessor_instance_vars(params, values)
    end

    private

    def params_to_attr_accessor_instance_vars(params, values)
      params.each_with_index do |param, i|
        instance_variable_set("@#{param[1]}", values[i])
        self.class.class_eval {attr_accessor param[1]}
      end
    end
  end
end
