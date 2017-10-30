module SynapsePayRest
  # Stores info on the base document portion (personal/business info) of the CIP
  # document and also manages physical/social/virtual documents.
  class BaseDocument
    # @!attribute [rw] user
    #   @return [SynapsePayRest::User] the user to whom the transaction belongs
    # @!attribute [r] permission_scope
    #   @return [String] https://docs.synapsepay.com/docs/user-resources#section-document-permission-scope
    attr_accessor :user, :email, :phone_number, :ip, :name, :aka, :entity_type,
                  :entity_scope, :birth_day, :birth_month, :birth_year,
                  :address_street, :address_city, :address_subdivision,
                  :address_postal_code, :address_country_code, 
                  :physical_documents, :social_documents, :virtual_documents, 
                  :alias, :screening_results
    attr_reader :id, :permission_scope

    class << self 
      # Creates a new base document in the API belonging to the provided user and
      # returns a base document instance from the response data.
      # 
      # @param user [SynapsePayRest::User] the user to whom the base document belongs
      # @param email [String]
      # @param phone_number [String]
      # @param ip [String]
      # @param name [String]
      # @param aka [String] corresponds to 'alias' in docs, use name if no alias
      # @param entity_type [String] consult your organization's CIP for valid options
      # @see https://docs.synapsepay.com/docs/user-resources#section-supported-entity-types all supported entity_type values
      # @param entity_scope [String] consult your organization's CIP for valid options
      # @see https://docs.synapsepay.com/docs/user-resources#section-supported-entity-scope all entity_scope options
      # @param birth_day [Integer]
      # @param birth_month [Integer]
      # @param birth_year [Integer]
      # @param address_street [String]
      # @param address_city [String]
      # @param address_subdivision [String]
      # @param address_postal_code [String]
      # @param address_country_code [String]
      # @param physical_documents [Array<SynapsePayRest::PhysicalDocument>] (optional)
      # @param social_documents [Array<SynapsePayRest::SocialDocument>] (optional)
      # @param virtual_documents [Array<SynapsePayRest::VirtualDocument>] (optional)
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [SynapsePayRest::BaseDocument] new instance with updated info
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

        base_document = BaseDocument.new({
          "user"=>user,
          "email"=>email,
          "phone_number"=>phone_number,
          "ip"=>ip,
          "name"=>name,
          "aka"=>aka,
          "entity_type"=>entity_type,
          "entity_scope"=>entity_scope,
          "birth_day"=>birth_day,
          "birth_month"=>birth_month,
          "birth_year"=>birth_year,
          "address_street"=>address_street,
          "address_city"=>address_city,
          "address_subdivision"=>address_subdivision,
          "address_postal_code"=>address_postal_code,
          "address_country_code"=>address_country_code,
          "physical_documents"=>physical_documents,
          "social_documents"=>social_documents,
          "virtual_documents"=>virtual_documents
        })
        base_document.submit
      end

      # Parses multiple base_documents from response
      # @note Do not call directly (it's automatic).
      def from_response(user, response)
        base_documents_data = response['documents']
        base_documents_data.map do |base_document_data|
          physical_docs = base_document_data['physical_docs'].map do |data|
            doc = PhysicalDocument.from_response(data)
            doc.base_document = self
            doc
          end
          social_docs = base_document_data['social_docs'].map do |data|
            doc = SocialDocument.from_response(data)
            doc.base_document = self
            doc
          end
          virtual_docs = base_document_data['virtual_docs'].map do |data|
            doc = VirtualDocument.from_response(data)
            doc.base_document = self
            doc
          end

          args = {
            "user"=>user,
            "id"=>base_documents_data.first['id'],
            "name"=>base_documents_data.first['name'],
            "permission_scope"=>base_documents_data.first['permission_scope'],
            "address_city"=>base_documents_data.first['address_city'],
            "address_country_code"=>base_documents_data.first['address_country_code'],
            "address_postal_code"=>base_documents_data.first['address_postal_code'],
            "address_street"=>base_documents_data.first['address_street'],
            "address_subdivision"=>base_documents_data.first['address_subdivision'],
            "alias"=>base_documents_data.first['alias'],
            "birth_day"=>base_documents_data.first['day'],
            "email"=>base_documents_data.first['email'],
            "entity_scope"=>base_documents_data.first['entity_scope'],
            "entity_type"=>base_documents_data.first['entity_type'],
            "ip"=>base_documents_data.first['ip'],
            "birth_month"=>base_documents_data.first['month'],
            "phone_number"=>base_documents_data.first['phone_number'],
            "birth_year"=>base_documents_data.first['year'],
            "screening_results"=>base_documents_data.first['screening_results'],
            "physical_documents"=>physical_docs,
            "social_documents"=>social_docs,
            "virtual_documents"=>virtual_docs
          }

          other_keys = base_document_data.keys

          ["physical_docs", "social_docs", "virtual_docs"].each do |item|
            other_keys.delete_at(other_keys.index(item))
          end

          for key in other_keys do
            if base_document_data.has_key?(key)
              args[key] = base_document_data[key]
            end
          end

          base_doc = self.new(args)
          [physical_docs, social_docs, virtual_docs].flatten.each do |doc|
            doc.base_document = base_doc
          end

          base_doc
        end
      end
    end

    # @note It should not be necessary to call this method directly.
    def initialize(args)
      @id                   = args["id"]
      @permission_scope     = args["permission_scope"]
      @user                 = args["user"]
      @email                = args["email"]
      @phone_number         = args["phone_number"]
      @ip                   = args["ip"]
      @name                 = args["name"]
      @aka                  = args["aka"]
      @entity_type          = args["entity_type"]
      @entity_scope         = args["entity_scope"]
      @birth_day            = args["birth_day"]
      @birth_month          = args["birth_month"]
      @birth_year           = args["birth_year"]
      @address_street       = args["address_street"]
      @address_city         = args["address_city"]
      @address_subdivision  = args["address_subdivision"]
      @address_postal_code  = args["address_postal_code"]
      @address_country_code = args["address_country_code"]
      @screening_results    = args["screening_results"]
      @physical_documents   = args["physical_documents"]
      @social_documents     = args["social_documents"]
      @virtual_documents    = args["virtual_documents"]
    end

    # Submits the base document to the API.
    # @note It should not be necessary to call this method directly.
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BaseDocument] new instance with updated info (id will be different if email or phone changed)
    def submit
      response = user.client.users.update(user_id: user.id, payload: payload_for_submit)
      @user    = User.from_response(user.client, response)

      if id
        # return updated version of self
        user.base_documents.find { |doc| doc.id == id }
      else
        # first time submission, assume last doc is updated version of self
        user.base_documents.last
      end
    end

    # Updates the supplied fields in the base document. See #create for valid
    # 
    # @param email [String] (optional)
    # @param phone_number [String] (optional)
    # @param ip [String] (optional)
    # @param name [String] (optional)
    # @param aka [String] (optional) corresponds to 'alias' in docs, use name if no alias
    # @param entity_type [String] (optional) consult your organization's CIP for valid options
    # @see https://docs.synapsepay.com/docs/user-resources#section-supported-entity-types all supported entity_type values
    # @param entity_scope [String] (optional) consult your organization's CIP for valid options
    # @see https://docs.synapsepay.com/docs/user-resources#section-supported-entity-scope all entity_scope options
    # @param birth_day [Integer] (optional)
    # @param birth_month [Integer] (optional)
    # @param birth_year [Integer] (optional)
    # @param address_street [String] (optional)
    # @param address_city [String] (optional)
    # @param address_subdivision [String] (optional)
    # @param address_postal_code [String] (optional)
    # @param address_country_code [String] (optional)
    # @param physical_documents [Array<SynapsePayRest::PhysicalDocument>] (optional)
    # @param social_documents [Array<SynapsePayRest::SocialDocument>] (optional)
    # @param virtual_documents [Array<SynapsePayRest::VirtualDocument>] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BaseDocument] new instance with updated info 
    # 
    # @todo validate changes are valid fields in base_document
    #   (or make other methods more like this)
    def update(**changes)
      if changes.empty?
        raise ArgumentError, 'must provide some key-value pairs to update'
      end
      payload  = payload_for_update(changes)
      response = user.client.users.update(user_id: user.id, payload: payload)
      @user    = User.from_response(user.client, response)

      if id
        # return updated version of self
        return user.base_documents.find { |doc| doc.id == id }
      else
        # first time submission, assume last doc is updated version of self
        return user.base_documents.last
      end
    end

    # Adds one or more physical documents to the base document and submits
    # them to the API using KYC 2.0 endpoints.
    # 
    # @param documents [Array<SynapsePayRest::PhysicalDocument>] (one or more documents)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BaseDocument] new instance with updated info
    def add_physical_documents(*documents)
      unless documents.first.is_a?(PhysicalDocument)
        raise ArgumentError, 'must contain a PhysicalDocument'
      end

      update(physical_documents: documents)
    end

    # Adds one or more social documents to the base document and submits
    # them to the API using KYC 2.0 endpoints.
    # 
    # @param documents [Array<SynapsePayRest::SocialDocument>] (one or more documents)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BaseDocument] new instance with updated info
    def add_social_documents(*documents)
      unless documents.first.is_a?(SocialDocument)
        raise ArgumentError, 'must contain a SocialDocument'
      end

      update(social_documents: documents)
    end

    # Adds one or more virtual documents to the base document and submits
    # them to the API using KYC 2.0 endpoints.
    # 
    # @param documents [Array<SynapsePayRest::VirtualDocument>] (one or more documents)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BaseDocument] new instance with updated info
    def add_virtual_documents(*documents)
      unless documents.first.is_a?(VirtualDocument)
        raise ArgumentError, 'must contain a VirtualDocument'
      end

      update(virtual_documents: documents)
    end

    # Checks if two BaseDocument instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? &&  id == other.id 
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
        payload['documents'].first['physical_docs'] = physical_documents.map(&:to_hash)
      end

      unless social_documents.empty?
        payload['documents'].first['social_docs'] = social_documents.map(&:to_hash)
      end

      unless virtual_documents.empty?
        payload['documents'].first['virtual_docs'] = virtual_documents.map(&:to_hash)
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
          payload['documents'].first['physical_docs'] = new_value.map(&:to_hash)
        elsif field == :social_documents
          payload['documents'].first['social_docs'] = new_value.map(&:to_hash)
        elsif field == :virtual_documents
          payload['documents'].first['virtual_docs'] = new_value.map(&:to_hash)
        else
          # insert non-document fields into payload
          payload['documents'].first[field.to_s] = new_value
        end
      end

      payload
    end
  end
end
