module SynapsePayRest
  class User
    attr_reader :client, :id, :logins, :phone_numbers, :legal_names, :note, 
                :supp_id, :is_business, :base_document_tag
    attr_accessor :refresh_token, :base_documents

    class << self
      # TODO: simplify the logins argument somehow. separate class?
      # used to make a new user
      def create(client:, logins:, phone_numbers:, legal_names:, **options)
        if [logins, phone_numbers, legal_names].any? { |arg| !arg.is_a? Array}
          raise ArgumentError, 'logins/phone_numbers/legal_names must be Array'
        end
        if [logins, phone_numbers, legal_names].any?(&:empty?)
          raise ArgumentError, 'logins/phone_numbers/legal_names cannot be empty'
        end
        if !logins.first.is_a? Hash
          raise ArgumentError, 'logins must contain at least one hash with :email key'
        end

        payload = payload_for_create(logins: logins, phone_numbers: phone_numbers, legal_names: legal_names, **options)
        response = client.users.create(payload: payload)
        create_from_response(client, response)
      end

      # fetches an existing user
      def find(client:, id:)
        response = client.users.get(user_id: id)
        create_from_response(client, response)
      end

      # fetches data for multiple users
      def all(client:, page: nil, per_page: nil, query: nil)
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

      # fetches data for users matching query in name/email
      def search(client:, query:, page: nil, per_page: nil)
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

      def create_multiple_from_response(client, response)
        return [] if response.empty?
        response.map { |user_data| create_from_response(client, user_data)}
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @client.http_client.user_id = @id
      @base_documents  ||= []
    end

    def update(**options)
      if options.empty?
        raise ArgumentError, 'must provide a key-value pair to update. keys: login,
          read_only, phone_number, legal_name, remove_phone_number, remove_login'
      end

      client.users.update(payload: payload_for_update(options))
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
  end
end
