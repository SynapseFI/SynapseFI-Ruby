module SynapsePayRest
  # Represents a user record and holds methods for constructing user objects
  # from API calls. This is built on top of the SynapsePayRest::Users class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  class User
    attr_reader :client, :id, :logins, :phone_numbers, :legal_names, :note, 
                :supp_id, :is_business, :base_document_tag
    attr_accessor :refresh_token, :base_documents

    class << self
      # Creates a new user in the API and returns a User object from the
      # response data.
      # 
      # @param client [SynapsePayRest::Client]
      # @param logins [Array<Hash>] 
      # @param phone_numbers [Array<String>]
      # @param legal_names [Array<String>]
      # @param note [String] (optional)
      # @param supp_id [String] (optional)
      # @param is_business [Boolean] (optional) API defaults to false
      # 
      # @example logins argument (only :email is required)
      #   [{
      #     email: "test@test.com", 
      #     password: "letmein", 
      #     read_only: false
      #   }]
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [SynapsePayRest::User]
      def create(client:, logins:, phone_numbers:, legal_names:, **options)
        # @todo simplify the logins argument somehow. separate class?
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        if [logins, phone_numbers, legal_names].any? { |arg| !arg.is_a? Array}
          raise ArgumentError, 'logins/phone_numbers/legal_names must be Array'
        end
        if [logins, phone_numbers, legal_names].any?(&:empty?)
          raise ArgumentError, 'logins/phone_numbers/legal_names cannot be empty'
        end
        unless logins.first.is_a? Hash
          raise ArgumentError, 'logins must contain at least one hash {email: (required), password:, read_only:}'
        end
        unless logins.first[:email].is_a?(String) && logins.first[:email].length > 0
          raise ArgumentError, 'logins must contain at least one hash with :email key'
        end

        payload = payload_for_create(logins: logins, phone_numbers: phone_numbers, legal_names: legal_names, **options)
        response = client.users.create(payload: payload)
        create_from_response(client, response)
      end

      # Queries the API for a user by id and returns a User objects if found.
      # 
      # @param client [SynapsePayRest::Client]
      # @param id [String] id of the user to find
      # 
      # @raise [SynapsePayRest::Error] if user not found or invalid client credentials
      # 
      # @return [SynapsePayRest::User]
      def find(client:, id:)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        response = client.users.get(user_id: id)
        create_from_response(client, response)
      end

      # Queries the API for all users (with optional filters) and returns them
      # as User objects.
      # 
      # @param client [SynapsePayRest::Client]
      # @param query [String] (optional) response will be filtered to 
      #   users with matching name/email
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [Array<SynapsePayRest::User>]
      def all(client:, page: nil, per_page: nil, query: nil)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end
        if query && !query.is_a?(String)
          raise ArgumentError, 'query must be a String'
        end

        response = client.users.get(page: page, per_page: per_page, query: query)
        create_multiple_from_response(client, response['users'])
      end

      # Queries the API for all users with name/email matching the given query
      # and returns them as User objects.
      # 
      # @param client [SynapsePayRest::Client]
      # @param query [String] response will be filtered to 
      #   users with matching name/email
      # @param page [String,Integer] (optional) response will default to 1
      # @param per_page [String,Integer] (optional) response will default to 20
      # 
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      # 
      # @return [Array<SynapsePayRest::User>]
      def search(client:, query:, page: nil, per_page: nil)
        all(client: client, query: query, page: page, per_page: per_page)
      end

      private

      # Maps args to API payload format.
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

      # Constructs a user object from a user response.
      def create_from_response(client, response)
        user = self.new(
          client:            client,
          id:                response['_id'],
          refresh_token:     response['refresh_token'],
          logins:            response['logins'],
          phone_numbers:     response['phone_numbers'],
          legal_names:       response['legal_names'],
          permission:        response['permission'],
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

      # Calls create_from_response on each member of a response collection.
      def create_multiple_from_response(client, response)
        return [] if response.empty?
        response.map { |user_data| create_from_response(client, user_data)}
      end
    end

    # User constructor. Do not use directly (use class methods)
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @client.http_client.user_id = @id
      @base_documents  ||= []
    end

    # Updates the given 
    def update(**options)
      if options.empty?
        raise ArgumentError, 'must provide a key-value pair to update. keys: login,
          read_only, phone_number, legal_name, remove_phone_number, remove_login'
      end

      client.users.update(payload: payload_for_update(options))
      update_instance_variables(options)
      self
    end

    def create_base_document(**args)
      base_document = BaseDocument.create(user: self, **args)
      @base_documents << base_document
      base_document
    end

    def add_login(email:, password: nil, read_only: nil)
      raise ArgumentError, 'email must be a String' unless email.is_a?(String)
      raise ArgumentError, 'password must be nil or String' if password && !password.is_a?(String)
      if read_only && ![true, false].include?(read_only)
        raise ArgumentError, 'read_only must be nil or Boolean' 
      end

      login = {'email' => email}
      login['password']  = password if password
      login['read_only'] = read_only if read_only
      update(login: login)
      @logins << login
      self
    end

    def remove_login(email:)
      raise ArgumentError, 'email must be a String' unless email.is_a? String

      login = {email: email}
      update(remove_login: login)
      @logins.delete_if { |l| l['email'] == email }
      self
    end

    def add_phone_number(phone_number)
      raise ArgumentError, 'phone_number must be a String' unless phone_number.is_a? String

      update(phone_number: phone_number)
      @phone_numbers << phone_number
      self
    end

    def remove_phone_number(phone_number)
      raise ArgumentError, 'phone_number must be a String' unless phone_number.is_a? String

      update(remove_phone_number: phone_number)
      @phone_numbers.delete(phone_number)
      self
    end

    def authenticate
      client.users.refresh(payload: payload_for_refresh)
    end

    def register_fingerprint(fingerprint)
      raise ArgumentError, 'fingerprint must be a String' unless fingerprint.is_a?(String)

      client.http_client.update_headers(fingerprint: fingerprint)
      response = client.users.refresh(payload: payload_for_refresh)
      response['phone_numbers']
    end

    def select_2fa_device(device)
      raise ArgumentError, 'device must be a String' unless device.is_a?(String)

      payload = payload_for_refresh
      payload['phone_number'] = device
      client.users.refresh(payload: payload)
    end

    def confirm_2fa_pin(pin:, device:)
      raise ArgumentError, 'pin must be a String' unless pin.is_a?(String)
      raise ArgumentError, 'device must be a String' unless device.is_a?(String)
      
      payload = payload_for_refresh
      payload['phone_number']   = device
      payload['validation_pin'] = pin
      client.users.refresh(payload: payload)
      :success
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

    def update_instance_variables(**args)
      @legal_names   << args[:legal_name] if args[:legal_name]
      @logins        << args[:login] if args[:login]
      @phone_numbers << args[:phone_number] if args[:phone_number]
      @logins.delete(args[:remove_login]) if args[:remove_login]
      @phone_numbers.delete(args[:remove_phone_number]) if args[:remove_phone_number]
      @read_only = args[:read_only] if args[:read_only]
      nil
    end
  end
end
