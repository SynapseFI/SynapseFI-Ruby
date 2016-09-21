module SynapsePayRest
  # this is a collection of personal info + documents
  # TODO: write to_payload methods
  class CipDocument
    attr_reader :email, :phone_number, :ip, :name, :alias, :entity_type,
                :entity_scope, :birth_day, :birth_month, :birth_year,
                :address_street, :address_city, :address_subdivision,
                :address_postal_code, :address_country_code, :id, :documents,
                :user

    def initialize(user:, email:, phone_number:, ip:, name:, alias:,
      entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:, address_street:,
      address_city:, address_subdivision:, address_postal_code:,
      address_country_code:)
      @id = id
      @user = user
      @documents = []

      params = method(__method__).parameters.map { |param| param[1] }
      values = params.map { |param| binding.local_variable_get(param) }
      params_to_instance_variables(params, values)
    end

    # TODO: validate input type
    def add_documents(*documents)
      documents.each { |doc| doc.cip_document = self }
      @documents.concat(documents)
      self
    end

    # TODO: validate input type
    def submit
      payload = {
        'documents' => [{
          'email'                => email,
          'phone_number'         => phone_number,
          'ip'                   => ip,
          'name'                 => name,
          'alias'                => self.alias,
          'entity_type'          => entity_type,
          'entity_scope'         => entity_scope,
          'day'                  => birth_day,
          'month'                => birth_month,
          'year'                 => birth_year,
          'address_street'       => address_street,
          'address_city'         => address_city,
          'address_subdivision'  => address_subdivision,
          'address_postal_code'  => address_postal_code,
          'address_country_code' => address_country_code
        }]
      }

      # add documents to payload
      documents.each do |doc|
        if doc.category == :physical
          payload['documents'].first['physical_docs'] ||= []
          document = {'document_value' => doc.value, 'document_type' => doc.type}
          payload['documents'].first['physical_docs'] << document
        elsif doc.category == :virtual
          payload['documents'].first['virtual_docs'] ||= []
          document = {'document_value' => doc.value, 'document_type' => doc.type}
          payload['documents'].first['virtual_docs'] << document
        elsif doc.category == :social
          payload['documents'].first['social_docs'] ||= []
          document = {'document_value' => doc.value, 'document_type' => doc.type}
          payload['documents'].first['social_docs'] << document
        end
      end

      @user.authenticate
      response = @user.client.users.update(payload: payload)
      @id = response['_id']
      documents.each { |doc| doc.cip_document = self }
      self
    end

    private

    def params_to_instance_variables(params, values)
      params.each_with_index do |param, i|
        instance_variable_set("@#{param}", values[i])
      end
    end
  end
end
