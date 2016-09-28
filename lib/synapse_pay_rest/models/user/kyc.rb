module SynapsePayRest
  # TODO: write to_hash methods
  class Kyc
    attr_accessor :user, :email, :phone_number, :ip, :name, :alias, :entity_type,
                :entity_scope, :birth_day, :birth_month, :birth_year,
                :address_street, :address_city, :address_subdivision,
                :address_postal_code, :address_country_code, :permission_scope, 
                :id, :physical_documents, :social_documents, :virtual_documents

    class << self
      # TODO: clean this up
      def create(user:, email:, phone_number:, ip:, name:,
      alias:, entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:,
      address_street:, address_city:, address_subdivision:, address_postal_code:,
      address_country_code:, physical_documents: [], social_documents: [],
      virtual_documents: [])
        kyc = Kyc.new(user: user, email: email, phone_number: phone_number,
        ip: ip, name: name, alias: binding.local_variable_get(:alias), entity_type: entity_type,
        entity_scope: entity_scope, birth_day: birth_day, birth_month: birth_month, 
        birth_year: birth_year, address_street: address_street, address_city: address_city,
        address_subdivision: address_subdivision, address_postal_code:  address_postal_code,
        address_country_code: address_country_code, physical_documents: physical_documents,
        social_documents: social_documents, virtual_documents: virtual_documents)
        kyc.submit
      end

      # parses multiple kyc documents from response
      def create_from_response(user, response)
        kycs_data = response['documents']
        kycs_data.map do |kyc_data|
          physical_docs = kyc_data['physical_docs'].map do |data|
            PhysicalDocument.create_from_response_fields(data)
          end
          social_docs = kyc_data['social_docs'].map do |data|
            SocialDocument.create_from_response_fields(data)
          end
          virtual_docs = kyc_data['virtual_docs'].map do |data|
            VirtualDocument.create_from_response_fields(data)
          end

          Kyc.new(user: user, id: kyc_data['id'], name: kyc_data['name'],
            permission_scope: kyc_data['permission_scope'], physical_documents: physical_docs,
            social_documents: social_docs, virtual_documents: virtual_docs)
        end
      end
    end

    # TODO: validate input types
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }

      @physical_documents ||= []
      @social_documents   ||= []
      @virtual_documents  ||= []

      # associate this kyc doc with each doc
      [physical_documents, social_documents, virtual_documents].flatten.each do |doc|
        doc.kyc = self
      end
    end
    
    # TODO: refactor
    # TODO: validate input type
    def submit
      user.authenticate
      response = @user.client.users.update(payload: payload_for_submit)

      update_values_with_response_data(response)
      update_document_values_with_response_data(response)

      self
    end

    # TODO: validates changes are valid fields in kyc
    # TODO: handle when user tries to update a new doc instead of existing
    # TODO: important to determine which documents overwrite and which duplicate
    def update(**changes)
      payload = payload_for_update(changes)
      response = user.client.users.update(payload: payload)

      update_values_not_verified_in_response(changes)
      update_values_with_response_data(response)
      update_document_values_with_response_data(response)

      self
    end

    private

    def payload_for_submit
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

      unless physical_documents.empty?
        payload['documents'].first['physical_docs'] = physical_documents.map do |doc|
          doc.to_hash
        end
      end

      unless social_documents.empty?
        payload['documents'].first['social_docs'] = social_documents.map do |doc|
          doc.to_hash
        end
      end

      unless virtual_documents.empty?
        payload['documents'].first['virtual_docs'] = virtual_documents.map do |doc|
          doc.to_hash
        end
      end

      payload
    end

    def payload_for_update(changes)
      payload = {
        'documents' => [{
         'id' => id
        }]
      }

      changes.each do |field, new_value|
        if field == :physical_documents
          payload['documents'].first['physical_docs'] = physical_documents.map do |doc|
            doc.to_hash
          end
        elsif field == :social_documents
          payload['documents'].first['social_docs'] = social_documents.map do |doc|
            doc.to_hash
          end
        elsif field == :virtual_documents
          payload['documents'].first['virtual_docs'] = virtual_documents.map do |doc|
            doc.to_hash
          end
        else
          payload['documents'].first[field.to_s] = new_value
        end
      end

      payload
    end

    def update_values_with_response_data(response)
      if id
        # updated values, find kyc doc by id
        kyc_fields = response['documents'].find { |doc| doc['id'] == id}
      else
        # first time values, use latest kyc doc if multiple
        kyc_fields = response['documents'].last
        self.id = kyc_fields['id']
        self
      end
    end

    # TODO: move some of this logic to Document
    def update_document_values_with_response_data(response)
      if id
        # updated values, find kyc doc by id. id 
        kyc_fields = response['documents'].find { |doc| doc['id'] == id}
        # sometimes id from API changes :(
        if kyc_fields.nil? 
          kyc_fields = response['documents'].last
          self.id = kyc_fields['id']
        end
      else
        # first time values, use latest kyc doc if multiple
        kyc_fields = response['documents'].last
        self.id = kyc_fields['id']
      end

      [physical_documents, social_documents, virtual_documents].flatten.each do |doc|

        if doc.is_a? PhysicalDocument
          same_types = kyc_fields['physical_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        elsif doc.is_a? SocialDocument
          same_types = kyc_fields['social_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        elsif doc.is_a? VirtualDocument
          same_types = kyc_fields['virtual_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        end

        # this probably won't work if there are multiple of same type
        doc_data = same_types.max_by { |x| x['last_updated'] }
        doc.update_from_response_fields(doc_data)
      end

      self
    end

    # updates changed values that don't come back in response data
    def update_values_not_verified_in_response(changes)
      changes.each do |field, new_value|
        if [:physical_documents, :social_documents, :virtual_documents].include? field
          new_value.each do |doc|
            doc.id = id
            doc.kyc = self
            physical_documents << doc if doc.is_a? PhysicalDocument
            social_documents << doc if doc.is_a? SocialDocument
            virtual_documents << doc if doc.is_a? VirtualDocument
          end
        else
          # use attr_accessor to update instance variables
          self.send("#{field}=", new_value)
        end
      end

      self
    end
  end
end
