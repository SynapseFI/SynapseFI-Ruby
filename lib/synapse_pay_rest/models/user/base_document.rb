module SynapsePayRest
  class BaseDocument
    attr_accessor :user, :email, :phone_number, :ip, :name, :aka, :entity_type,
                  :entity_scope, :birth_day, :birth_month, :birth_year,
                  :address_street, :address_city, :address_subdivision,
                  :address_postal_code, :address_country_code, :permission_scope, 
                  :id, :physical_documents, :social_documents, :virtual_documents

    class << self
      def create(user:, email:, phone_number:, ip:, name:,
        aka:, entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:,
        address_street:, address_city:, address_subdivision:, address_postal_code:,
        address_country_code:, physical_documents: [], social_documents: [],
        virtual_documents: [])
        raise ArgumentError, 'user must be a User object' unless user.is_a?(User)
        [email, phone_number, ip, name, aka, entity_type, entity_scope, 
         address_street, address_city, address_subdivision, address_postal_code,
         address_country_code].each do |arg|
           raise ArgumentError, "#{arg} must be a String" unless arg.is_a?(String)
        end
        [physical_documents, social_documents, virtual_documents].each do |arg|
          raise ArgumentError, "#{arg} must be an Array" unless arg.is_a?(Array)
        end
        unless physical_documents.empty? || physical_documents.first.is_a?(PhysicalDocument)
          raise ArgumentError, 'physical_documents be empty or contain PhysicalDocument(s)'
        end
        unless social_documents.empty? || social_documents.first.is_a?(SocialDocument)
          raise ArgumentError, 'social_documents be empty or contain SocialDocument(s)'
        end
        unless virtual_documents.empty? || virtual_documents.first.is_a?(VirtualDocument)
          raise ArgumentError, 'virtual_documents be empty or contain VirtualDocument(s)'
        end

        base_document = BaseDocument.new(user: user, email: email, phone_number: phone_number,
          ip: ip, name: name, aka: aka, entity_type: entity_type,
          entity_scope: entity_scope, birth_day: birth_day, birth_month: birth_month, 
          birth_year: birth_year, address_street: address_street, address_city: address_city,
          address_subdivision: address_subdivision, address_postal_code:  address_postal_code,
          address_country_code: address_country_code, physical_documents: physical_documents,
          social_documents: social_documents, virtual_documents: virtual_documents)
        base_document.submit
      end

      # parses multiple base_documents from response
      def create_from_response(user, response)
        base_documents_data = response['documents']
        base_documents_data.map do |base_document_data|
          physical_docs = base_document_data['physical_docs'].map do |data|
            PhysicalDocument.create_from_response(data)
          end
          social_docs = base_document_data['social_docs'].map do |data|
            SocialDocument.create_from_response(data)
          end
          virtual_docs = base_document_data['virtual_docs'].map do |data|
            VirtualDocument.create_from_response(data)
          end

          args = {
            user:               user,
            id:                 base_document_data['id'],
            name:               base_document_data['name'],
            permission_scope:   base_document_data['permission_scope'],
            physical_documents: physical_docs,
            social_documents:   social_docs,
            virtual_documents:  virtual_docs
          }

          self.new(args)
        end
      end
    end

    def initialize(**args)
      @user                 = args[:user]
      @email                = args[:email]
      @phone_number         = args[:phone_number]
      @ip                   = args[:ip]
      @name                 = args[:name]
      @aka                  = args[:aka]
      @entity_type          = args[:entity_type]
      @entity_scope         = args[:entity_scope]
      @birth_day            = args[:birth_day]
      @birth_month          = args[:birth_month]
      @birth_year           = args[:birth_year]
      @address_street       = args[:address_street]
      @address_city         = args[:address_city]
      @address_subdivision  = args[:address_subdivision]
      @address_postal_code  = args[:address_postal_code]
      @address_country_code = args[:address_country_code]
      @physical_documents   = args[:physical_documents]
      @social_documents     = args[:social_documents]
      @virtual_documents    = args[:virtual_documents]

      # associate this base_document doc with each doc
      unless [physical_documents, social_documents, virtual_documents].all?(&:empty?)
        [physical_documents, social_documents, virtual_documents].flatten.each do |doc|
          doc.base_document = self
        end
      end
    end

    def submit
      user.authenticate
      response = @user.client.users.update(payload: payload_for_submit)
      update_values_with_response_data(response)
      update_document_values_with_response_data(response)
      self
    end

    # TODO: validate changes are valid fields in base_document
    def update(**changes)
      if changes.empty?
        raise ArgumentError, 'must provide some key-value pairs to update'
      end
      user.authenticate
      payload = payload_for_update(changes)
      response = user.client.users.update(payload: payload)

      update_values_not_verified_in_response(changes)
      update_values_with_response_data(response)
      update_document_values_with_response_data(response)

      self
    end

    def add_physical_documents(documents)
      raise ArgumentError, 'must be an Array' unless documents.is_a?(Array)
      unless documents.first.is_a?(PhysicalDocument)
        raise ArgumentError, 'must contain a PhysicalDocument'
      end

      update(physical_documents: documents)
    end

    def add_social_documents(documents)
      raise ArgumentError, 'must be an Array' unless documents.is_a?(Array)
      unless documents.first.is_a?(SocialDocument)
        raise ArgumentError, 'must contain a SocialDocument'
      end

      update(social_documents: documents)
    end

    def add_virtual_documents(documents)
      raise ArgumentError, 'must be an Array' unless documents.is_a?(Array)
      unless documents.first.is_a?(VirtualDocument)
        raise ArgumentError, 'must contain a VirtualDocument'
      end

      update(virtual_documents: documents)
    end

    private

    def payload_for_submit
      payload = {
        'documents' => [{
          'email'                => email,
          'phone_number'         => phone_number,
          'ip'                   => ip,
          'name'                 => name,
          'alias'                => aka,
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
        # convert docs to their hash format for payload
        if field == :physical_documents
          payload['documents'].first['physical_docs'] = new_value.map { |doc| doc.to_hash }
        elsif field == :social_documents
          payload['documents'].first['social_docs'] = new_value.map { |doc| doc.to_hash }
        elsif field == :virtual_documents
          payload['documents'].first['virtual_docs'] = new_value.map { |doc| doc.to_hash }
        else
          # insert non-document fields into payload
          payload['documents'].first[field.to_s] = new_value
        end
      end

      payload
    end

    def update_values_with_response_data(response)
      if id
        # updated values, find base_document doc by id
        base_document_fields = response['documents'].find { |doc| doc['id'] == id}
      else
        # first time values, use latest base_document doc if multiple
        base_document_fields = response['documents'].last
        self.id = base_document_fields['id']
        self
      end
    end

    def update_document_values_with_response_data(response)
      base_document_fields = base_document_fields_from_response(response)

      [physical_documents, social_documents, virtual_documents].flatten.each do |doc|
        if doc.is_a? PhysicalDocument
          same_types = base_document_fields['physical_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        elsif doc.is_a? SocialDocument
          same_types = base_document_fields['social_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        elsif doc.is_a? VirtualDocument
          same_types = base_document_fields['virtual_docs'].select do |resp_doc|
            resp_doc['document_type'] == doc.type
          end
        end

        # assumes the most recently updated is the correct data to use
        doc_data = same_types.max_by { |x| x['last_updated'] }
        doc.update_from_response(doc_data)
      end

      self
    end

    def base_document_fields_from_response(response)
      if id
        # updated values, find base_document doc by id.
        base_document_fields = response['documents'].find { |doc| doc['id'] == id}
        # sometimes doc id changes so assume last one is the correct one
        if base_document_fields.nil? 
          base_document_fields = response['documents'].last
          self.id = base_document_fields['id']
        end
      else
        # first time submission, use last base_document for id if multiple
        base_document_fields = response['documents'].last
        self.id = base_document_fields['id']
      end
      base_document_fields
    end

    # updates changed values that don't come back in response data
    def update_values_not_verified_in_response(changes)
      changes.each do |field, new_value|
        # handle instantiation of docs
        if [:physical_documents, :social_documents, :virtual_documents].include? field
          new_value.each do |doc|
            doc.id = id
            doc.base_document = self
            physical_documents << doc if doc.is_a? PhysicalDocument
            social_documents   << doc if doc.is_a? SocialDocument
            virtual_documents  << doc if doc.is_a? VirtualDocument
          end
        # handle other response values by updating instance vars
        else
          self.send("#{field}=", new_value)
        end
      end

      self
    end
  end
end
