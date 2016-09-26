module SynapsePayRest
  class User
    attr_reader :client, :logins, :phone_numbers, :legal_names, :note, :supp_id,
                :is_business, :kyc_tag, :nodes
    attr_accessor :id, :refresh_token, :kycs

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

      # TODO: handle error if id not found
      # used to fetch an existing user
      def find(client:, id:)
        response = client.users.get(user_id: id)
        create_from_response(client, response)
      end

      # fetches data for multiple users
      def all(client:, page: 1, per_page: 20)
        response = client.users.get(page: page, per_page: per_page)
        response['users'].map { |data| create_from_response(client, data) }
      end

      # fetches data for users matching query in name/email
      def search(client:, query:, page: 1, per_page: 20)
        response = client.users.get(query: query, page: page, per_page: per_page)
        response['users'].map { |data| create_from_response(client, data) }
      end

      private

      def payload_for_create(logins:, phone_numbers:, legal_names:, **options)
        payload = {
          'logins'        => logins,
          'phone_numbers' => phone_numbers,
          'legal_names'   => legal_names,
          'extra'         => {}
        }
        # TODO: refactor
        # optional payload fields
        payload['extra']['note']        = options[:note] if options[:note]
        payload['extra']['supp_id']     = options[:supp_id] if options[:supp_id]
        payload['extra']['is_business'] = options[:is_business] if options[:is_business]
        payload['extra']['kyc_tag']     = options[:kyc_tag] if options[:kyc_tag]
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
          kyc_tag:       response['extra']['kyc_tag']
        )

        unless response['documents'].empty?
          kycs = Kyc.create_from_response(user, response)
          user.kycs = kycs
        end

        user
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @client.http_client.user_id = @id
      @kycs  ||= []
      @nodes ||= []
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
    def create_kyc(email:, phone_number:, ip:, name:,
      alias:, entity_type:, entity_scope:, birth_day:, birth_month:, birth_year:,
      address_street:, address_city:, address_subdivision:, address_postal_code:,
      address_country_code:, physical_documents: [], social_documents: [],
      virtual_documents: [])
      kyc = Kyc.create(user: self, email: email, phone_number: phone_number,
        ip: ip, name: name, alias: binding.local_variable_get(:alias), entity_type: entity_type,
        entity_scope: entity_scope, birth_day: birth_day, birth_month: birth_month, 
        birth_year: birth_year, address_street: address_street, address_city: address_city,
        address_subdivision: address_subdivision, address_postal_code:  address_postal_code,
        address_country_code: address_country_code, physical_documents: physical_documents,
        social_documents: social_documents, virtual_documents: virtual_documents)
      @kycs << kyc

      kyc
    end

    def authenticate
      client.users.refresh(payload: {'refresh_token' => refresh_token})
    end

    # TODO: need to test with and w/o fingerprint
    def verify_fingerprint
    end

    # TODO: low priority
    # def add_login(email:, password: nil)
    # end

    # TODO: validate arg values in allowed range
    def fetch_nodes(page: 1, per_page: 20, type: nil)
      authenticate
      response = client.nodes.get(page: page, per_page: per_page, type: type)
      # TODO
    end

    def fetch_node(id:)
    end

    def create_node_synapse_us()
      @nodes << node
    end

    # TODO: handle MFA
    def create_node_ach_us_via_bank_login()
      @nodes << node
    end

    def create_node_ach_us()
      @nodes << node
    end

    def create_node_wire_us()
    end

    def create_node_wire_int()
    end

    def create_node_reserve_us()
    end

    def create_node_synapse_ind()
    end

    def create_node_synapse_np()
    end

    def create_node_eft_ind()
    end

    def create_node_eft_np()
    end

    def create_node_iou()
    end

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

    def payload_for_fetch_nodes
      payload = {

      }
    end
  end
end
