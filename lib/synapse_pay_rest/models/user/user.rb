module SynapsePayRest
  class User
    attr_reader :client, :id, :logins, :phone_numbers, :legal_names, :note, 
                :supp_id, :is_business, :base_document_tag, :base_documents
    attr_accessor :refresh_token

    class << self
      # TODO: simplify the logins argument
      # used to make a new user
      def create(client:, logins:, phone_numbers:, legal_names:, **options)
        raise ArgumentError if [logins, phone_numbers, legal_names].any? { |arg| !arg.is_a? Array}
        raise ArgumentError, 'array argument cannot be empty' if [logins, phone_numbers, legal_names].any?(&:empty?)
        raise ArgumentError, 'logins must contain at least one hash with :email key' if logins && logins.first[:email].empty?

        payload = payload_for_create(logins: logins, phone_numbers: phone_numbers, legal_names: legal_names, **options)
        response = client.users.create(payload: payload)
        create_from_response(client, response)
      end

      # used to fetch an existing user
      def find(client:, id:)
        response = client.users.get(user_id: id)
        create_from_response(client, response)
      end

      # fetches data for multiple users
      def all(client:, page: 1, per_page: 20, query: nil)
        response = client.users.get(page: page, per_page: per_page, query: query)
        response['users'].map { |data| create_from_response(client, data) }
      end

      # fetches data for users matching query in name/email
      def search(client:, query:, page: 1, per_page: 20)
        all(client: client, query: query, page: page, per_page: per_page)
      end

      private

      def payload_for_create(logins:, phone_numbers:, legal_names:, **options)
        payload = {
          'logins'        => logins,
          'phone_numbers' => phone_numbers,
          'legal_names'   => legal_names,
        }
        # optional payload fields
        extra = {}
        extra['note']        = options[:note] if options[:note]
        extra['supp_id']     = options[:supp_id] if options[:supp_id]
        extra['is_business'] = options[:is_business] if options[:is_business]
        extra['base_document_tag']     = options[:base_document_tag] if options[:base_document_tag]
        payload['extra'] = extra if extra.any?

        payload
      end

      # builds a user object from a user response
      def create_from_response(client, response)
        user = self.new(
          client:            client,
          id:                response['_id'],
          refresh_token:     response['refresh_token'],
          logins:            response['logins'],
          phone_numbers:     response['phone_numbers'],
          legal_names:       response['legal_names'],
          note:              response['extra']['note'],
          supp_id:           response['extra']['supp_id'],
          is_business:       response['extra']['is_business'],
          base_document_tag: response['extra']['base_document_tag']
        )

        unless response['documents'].empty?
          base_documents = BaseDocument.create_from_response(user, response)
          user.base_documents = base_documents
        end

        user
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @client.http_client.user_id = @id
      @base_documents  ||= []
    end

    # TODO: validate some kind of proper input was entered
    # TODO: add convenience methods for add login, add email, etc.
    def update(**options)
      client.users.update(payload: payload_for_update(options))
      self
    end

    # TODO: refactor
    # TODO: validate arg format
    def create_base_document(email:, phone_number:, ip:, name:,
      alias:, entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:,
      address_street:, address_city:, address_subdivision:, address_postal_code:,
      address_country_code:, physical_documents: [], social_documents: [],
      virtual_documents: [])
      base_document = BaseDocument.create(user: self, email: email, phone_number: phone_number,
        ip: ip, name: name, alias: binding.local_variable_get(:alias), entity_type: entity_type,
        entity_scope: entity_scope, birth_day: birth_day, birth_month: birth_month, 
        birth_year: birth_year, address_street: address_street, address_city: address_city,
        address_subdivision: address_subdivision, address_postal_code:  address_postal_code,
        address_country_code: address_country_code, physical_documents: physical_documents,
        social_documents: social_documents, virtual_documents: virtual_documents)
      @base_documents << base_document

      base_document
    end

    def add_login(email:, password: nil, read_only: nil)
      login = {'email' => email}
      login['password']  = password if password
      login['read_only'] = read_only if read_only
      update(login: login)
      @logins << login
      self
    end

    def remove_login(email:)
      login = {email: email}
      update(remove_login: login)
      @logins.delete_if { |login| login['email'] == email }
      self
    end

    def add_phone_number(phone_number)
      update(phone_number: phone_number)
      @phone_numbers << phone_number
      self
    end

    def remove_phone_number(phone_number)
      update(remove_phone_number: phone_number)
      @phone_numbers.delete(phone_number)
      self
    end

    def authenticate
      client.users.refresh(payload: payload_for_refresh)
    end

    # TODO: need to test with and w/o fingerprint
    def verify_fingerprint
    end

    def nodes(**options)
      Node.all(user: self, **options)
    end

    def find_node(id:)
      Node.find(user: self, id: id)
    end

    def create_ach_us_node(**options)
      AchUsNode.create(user: self, **options)
    end

    def create_ach_us_nodes_via_bank_login(**options)
      AchUsNode.create_via_bank_login(user: self, **options)
    end

    def create_eft_ind_node(**options)
      EftIndNode.create(user: self, **options)
    end

    def create_eft_np_node(**options)
      EftNpNode.create(user: self, **options)
    end

    def create_iou_node(**options)
      IouNode.create(user: self, **options)
    end

    def create_reserve_us_node(**options)
      ReserveUsNode.create(user: self, **options)
    end

    def create_synapse_ind_node(**options)
      SynapseIndNode.create(user: self, **options)
    end

    def create_synapse_np_node(**options)
      SynapseNpNode.create(user: self, **options)
    end
    
    def create_synapse_us_node(**options)
      SynapseUsNode.create(user: self, **options)
    end

    def create_wire_us_node(**options)
      WireUsNode.create(user: self, **options)
    end

    def create_wire_int_node(**options)
      WireIntNode.create(user: self, **options)
    end

    def ==(other)
      other.instance_of?(self.class) && !id.nil? &&  id == other.id 
    end

    private

    def payload_for_update(**options)
      payload = {
        'refresh_token' => refresh_token,
        'update' => {}
      }
      # must have one of these
      payload['update']['login']               = options[:login] if options[:login]
      payload['update']['remove_login']        = options[:remove_login] if options[:remove_login]
      payload['update']['legal_name']          = options[:legal_name] if options[:legal_name]
      payload['update']['phone_number']        = options[:phone_number] if options[:phone_number]
      payload['update']['remove_phone_number'] = options[:remove_phone_number] if options[:remove_phone_number]
      payload
    end

    def payload_for_refresh
      {'refresh_token' => refresh_token}
    end
  end
end
