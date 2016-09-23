module SynapsePayRest
  class User
    attr_reader :client, :logins, :phone_numbers, :legal_names, :note, :supp_id,
                :is_business, :cip_tag
    attr_accessor :id, :refresh_token, :cip_documents

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
      # handle error if id not found
      def find(client:, id:)
        response = client.users.get(user_id: id)
        create_from_response(client, response)
      end

      # fetches data for multiple users
      def all(client:, page: 1, per_page: 15)
        response = client.users.get(options: {page: page, per_page: per_page})
        response['users'].map { |data| create_from_response(client, data) }
      end

      # fetches data for users matching query in name/email
      def search(client:, query:, page: 1, per_page: 15)
        response = client.users.get(options: {query: query, page: page, per_page: per_page})
        response['users'].map { |data| create_from_response(client, data) }
      end

      private

      def payload_for_create(logins:, phone_numbers:, legal_names:, **options)
        payload = {
          'logins' => logins,
          'phone_numbers' => phone_numbers,
          'legal_names' => legal_names,
          'extra' => {}
        }
        # TODO: refactor
        # optional payload fields
        payload['extra']['note']        = options[:note] if options[:note]
        payload['extra']['supp_id']     = options[:supp_id] if options[:supp_id]
        payload['extra']['is_business'] = options[:is_business] if options[:is_business]
        payload['extra']['cip_tag']     = options[:cip_tag] if options[:cip_tag]
        payload
      end

      # builds a user object from a user response
      def create_from_response(client, response)
        user = User.new(
          client:        client,
          id:            response['_id'],
          refresh_token: response['refresh_token'],
          logins:        response['logins'],
          phone_numbers: response['phone_numbers'],
          legal_names:   response['legal_names'],
          note:          response['extra']['note'],
          supp_id:       response['extra']['supp_id'],
          is_business:   response['extra']['is_business'],
          cip_tag:       response['extra']['cip_tag']
        )

        unless response['documents'].empty?
          cip_docs = CipDocument.create_from_response(user, response)
          user.cip_documents = cip_docs
        end

        user
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @client.http_client.user_id = @id
      @cip_documents ||= []
    end

    # TODO: validate some kind of proper input was entered
    # TODO: add convenience methods for add login, add email, etc.
    def update(**options)
      payload = payload_for_update(options)
      client.users.update(payload: payload)

      self
    end

    # TODO: refactor
    # TODO: validate arg format
    def create_cip_document(email:, phone_number:, ip:, name:,
      alias:, entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:,
      address_street:, address_city:, address_subdivision:, address_postal_code:,
      address_country_code:, physical_documents: [], social_documents: [],
      virtual_documents: [])
      cip_doc = CipDocument.create(user: self, email: email, phone_number: phone_number,
        ip: ip, name: name, alias: binding.local_variable_get(:alias), entity_type: entity_type,
        entity_scope: entity_scope, birth_day: birth_day, birth_month: birth_month, 
        birth_year: birth_year, address_street: address_street, address_city: address_city,
        address_subdivision: address_subdivision, address_postal_code:  address_postal_code,
        address_country_code: address_country_code, physical_documents: physical_documents,
        social_documents: social_documents, virtual_documents: virtual_documents)
      @cip_documents << cip_doc

      self
    end

    def authenticate
      client.users.refresh(payload: {'refresh_token' => refresh_token})
    end

    # TODO: need to test with and w/o fingerprint
    def verify_fingerprint
    end

    def verify_kba

    end

    # def add_login(email:, password: nil)
    # end

    # def create_node(node)
    #   @nodes << node
    # end

    # def nodes
    # end

    private

    def payload_for_update(options)
      payload = {
        'refresh_token' => refresh_token,
        'update' => {}
      }
      # must have one of these
      payload['update']['login'] = options[:login] if options[:login]
      payload['update']['remove_login'] = options[:remove_login] if options[:remove_login]
      payload['update']['legal_name'] = options[:legal_name] if options[:legal_name]
      payload['update']['phone_number'] = options[:phone_number] if options[:phone_number]
      payload['update']['remove_phone_number'] = options[:remove_phone_number] if options[:remove_phone_number]
      payload
    end
  end
end
