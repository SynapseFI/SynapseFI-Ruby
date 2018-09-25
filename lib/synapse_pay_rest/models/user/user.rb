module SynapsePayRest
  # Represents a user record and holds methods for constructing user instances
  # from API calls. This is built on top of the SynapsePayRest::Users class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  # 
  # @todo use mixins to remove duplication between Node and BaseNode.
  # @todo reduce duplicated logic between User/BaseNode/Transaction
  class User
    # @!attribute [rw] base_documents
    #   @return [Array<SynapsePayRest::BaseDocument>]
    # @!attribute [r] permission
    #   @return [String] https://docs.synapsepay.com/docs/user-resources#section-user-permissions
    attr_reader :client, :id, :logins, :phone_numbers, :legal_names, :note, 
                :supp_id, :is_business, :cip_tag, :permission
    attr_accessor :refresh_token, :base_documents, :oauth_key, :expires_in, :flag, :ips

    class << self
      # Creates a new user in the API and returns a User instance from the
      # response data.
      # 
      # @param client [SynapsePayRest::Client]
      # @param logins [Array<Hash>] 
      # @param phone_numbers [Array<String>]
      # @param legal_names [Array<String>]
      # @param note [String] (optional)
      # @param supp_id [String] (optional)
      # @param is_business [Boolean] (optional) API defaults to false
      # @param cip_tag [Integer] (optional) the CIP tag to use in this users CIP doc
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
      # 
      # @todo simplify the logins argument somehow. separate class?
      def create(client:, logins:, phone_numbers:, legal_names:, **options)
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
        from_response(client, response)
      end

      # Queries the API for a user by id and returns a User instances if found.
      # 
      # @param client [SynapsePayRest::Client]
      # @param id [String] id of the user to find
      # @param full_dehydrate [String] (optional) if 'yes', returns all KYC on user
      # 
      # @raise [SynapsePayRest::Error] if user not found or invalid client credentials
      # 
      # @return [SynapsePayRest::User]
      def find(client:, id:, full_dehydrate:'no')
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        raise ArgumentError, 'id must be a String' unless id.is_a?(String)

        response = client.users.get(user_id: id, full_dehydrate: full_dehydrate)
        
        from_response(client, response)
      end

      # Queries the API for all users (with optional filters) and returns them
      # as User instances.
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
      # 
      # @note users created this way are not automatically OAuthed
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
        multiple_from_response(client, response['users'])
      end

      # Queries the API for all users with name/email matching the given query
      # and returns them as User instances.
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
      # 
      # @note users created this way are not automatically OAuthed
      def search(client:, query:, page: nil, per_page: nil)
        all(client: client, query: query, page: page, per_page: per_page)
      end

      # Maps args to API payload format.
      # @note Do not call directly.
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
        extra['cip_tag']     = options[:cip_tag] if options[:cip_tag]
        payload['extra']     = extra if extra.any?

        payload
      end

      # Constructs a user instance from a user response.
      # @note Do not call directly.
      def from_response(client, response, oauth: true)
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
          cip_tag:           response['extra']['cip_tag'],
          flag:              nil,
          ips:               nil,
          oauth_key:         nil,
          expires_in:        nil
        )

        if response.has_key?('flag')
          user.flag = response['flag']
        end

        if response.has_key?('ips')
          user.ips = response['ips']
        end

        unless response['documents'].empty?
          base_documents = BaseDocument.from_response(user, response)
          user.base_documents = base_documents
        end
        oauth ? user.authenticate : user
      end

      # Calls from_response on each member of a response collection.
      # @note users created this way are not automatically OAuthed
      def multiple_from_response(client, response)
        return [] if response.empty?
        response.map { |user_data| from_response(client.dup, user_data, oauth: false)}
      end
    end

    # @note Do not call directly. Use User.create or other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
      @base_documents  ||= []
    end

    # Updates the oauth token.
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] (new instance with updated tokens)
    def authenticate
      response        = client.users.refresh(user_id: id, payload: payload_for_refresh)
      self.oauth_key  = response['oauth_key']
      self.expires_in = response['expires_in']
      self
    end

    # Updates the given key value pairs.
    # 
    # @param login [Hash]
    # @param phone_number [String]
    # @param legal_name [String]
    # @param remove_login [Hash]
    # @param remove_phone_number [String]
    # @param read_only [Boolean]
    # @param remove_legal_name [String]
    # 
    # @example login/remove_login argument (only email is required)
    #   {
    #     email: "test@test.com", 
    #     password: "letmein", 
    #     read_only: false
    #   }
    # 
    # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def update(**options)
      if options.empty?
        raise ArgumentError, 'must provide a key-value pair to update. keys: login,
          read_only, phone_number, legal_name, remove_phone_number, remove_login'
      end
      response = client.users.update(user_id: id, payload: payload_for_update(options))
      # return an updated user instance
      self.class.from_response(client, response)
    end

    # Creates a new base document for the user. To update an existing base
    # document, see SynapsePay::BaseDocument#update.
    # 
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
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def create_base_document(**args)
      BaseDocument.create(user: self, **args)
    end

    # Adds a login for the user.
    # 
    # @param email [String]
    # @param password [String] (optional)
    # @param read_only [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] (self)
    def add_login(email:, password: nil, read_only: nil)
      raise ArgumentError, 'email must be a String' unless email.is_a?(String)
      raise ArgumentError, 'password must be nil or String' if password && !password.is_a?(String)
      if read_only && ![true, false].include?(read_only)
        raise ArgumentError, 'read_only must be nil or Boolean' 
      end

      login = {'email' => email}
      # optional
      login['password']  = password if password
      login['read_only'] = read_only if read_only
      update(login: login)
    end

    # Removes a login from the user.
    # 
    # @param email [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def remove_login(email:)
      raise ArgumentError, 'email must be a String' unless email.is_a? String

      login = {email: email}
      update(remove_login: login)
    end

    # Add a phone_number to the user.
    # 
    # @param phone_number [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def add_phone_number(phone_number)
      raise ArgumentError, 'phone_number must be a String' unless phone_number.is_a? String

      update(phone_number: phone_number)
    end

    # Add a legal_name to the user.
    # 
    # @param legal_name [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def add_legal_name(legal_name)
      raise ArgumentError, 'legal_name must be a String' unless legal_name.is_a? String

      update(legal_name: legal_name)
    end

    # Removes a phone_number from the user.
    # 
    # @param phone_number [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def remove_phone_number(phone_number)
      raise ArgumentError, 'phone_number must be a String' unless phone_number.is_a? String

      update(remove_phone_number: phone_number)
    end

    # Removes a legal_name from the user
    # 
    # @param legal_name [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::User] new instance corresponding to same API record
    def remove_legal_name(legal_name)
      raise ArgumentError, 'legal_name must be a String' unless legal_name.is_a? String

      update(remove_legal_name: legal_name)
    end

    # Step 1 of fingerprint registration. Requests a new fingerprint be
    # registered to the user.
    # 
    # @param fingerprint [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<String>] array of devices (phone number / email)
    def register_fingerprint(fingerprint)
      raise ArgumentError, 'fingerprint must be a String' unless fingerprint.is_a?(String)

      client.http_client.update_headers(fingerprint: fingerprint)
      response = client.users.refresh(user_id: id, payload: payload_for_refresh)
      response['phone_numbers']
    end

    # Step 2 of fingerprint registration. Sends a request to the API to send a
    # 2FA PIN to the device specified. The device must be selected from return
    # value of #register_fingerprint.
    # 
    # @param device [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [:success] if successful
    def select_2fa_device(device)
      raise ArgumentError, 'device must be a String' unless device.is_a?(String)

      payload = payload_for_refresh
      payload['phone_number'] = device
      client.users.refresh(user_id: id, payload: payload)
      :success
    end

    # Step 3 (final) step of fingerprint registration. Confirms the PIN sent to
    # the device after calling #select_2fa_device (step 2).
    # 
    # @param pin [String]
    # @param device [String]
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [:success] if successful
    def confirm_2fa_pin(pin:, device:)
      raise ArgumentError, 'pin must be a String' unless pin.is_a?(String)
      raise ArgumentError, 'device must be a String' unless device.is_a?(String)
      
      payload = payload_for_refresh
      payload['phone_number']   = device
      payload['validation_pin'] = pin
      client.users.refresh(user_id: id, payload: payload)
      :success
    end

    # Queries the API for all nodes belonging to this user and returns them as
    # node (SynapsePayRest::BaseNode) instances.
    # 
    # @param page [String,Integer] (optional) response will default to 1
    # @param per_page [String,Integer] (optional) response will default to 20
    # @param type [String] (optional)
    # @see https://docs.synapsepay.com/docs/node-resources node types
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::BaseNode>] subclass d`epends on node types
    def nodes(**options)
      Node.all(user: self, **options)
    end

    # Queries the API for a node belonging to this user by node id and returns
    # a node instance if found.
    # 
    # @param id [String] id of the node to find
    # 
    # @raise [SynapsePayRest::Error] if node not found or other HTTP error
    # 
    # @return [SynapsePayRest::BaseNode] subclass depends on node type
    def find_node(id:)
      Node.find(user: self, id: id)
    end

    # Creates an ACH-US node via account and routing numbers, belonging to this user.
    # 
    # @param nickname [String] nickname for the node
    # @param account_number [String]
    # @param routing_number [String]
    # @param account_type [String] 'PERSONAL' or 'BUSINESS'
    # @param account_class [String] 'CHECKING' or 'SAVINGS'
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::AchUsNode]
    def create_ach_us_node(**options)
      AchUsNode.create(user: self, **options)
    end

    # Creates an ACH-US node via bank login, belonging to this user.
    # 
    # @param bank_name [String] 
    # @see https://synapsepay.com/api/v3/institutions/show valid bank_name options
    # @param username [String] user's bank login username
    # @param password [String] user's bank login password
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [Array<SynapsePayRest::AchUsNode>] may contain multiple nodes (checking and/or savings)
    def create_ach_us_nodes_via_bank_login(**options)
      AchUsNode.create_via_bank_login(user: self, **options)
    end

    # Creates an Unverified Node Class node via access token, belonging to this user
    # 
    # @param access_token [String] 
    # @see https://synapsepay.com/api/v3/institutions/show valid bank_name options
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [<SynapsePayRest::UnverifiedNode>] 
    def create_ach_us_nodes_via_bank_login_mfa(**options)
      AchUsNode.create_via_bank_login_mfa(user: self, **options)
    end

    # Creates an EFT-IND node.
    # 
    # @param nickname [String] nickname for the node
    # @param account_number [String]
    # @param ifsc [String]
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::EftIndNode]
    # 
    # @deprecated
    def create_eft_ind_node(**options)
      EftIndNode.create(user: self, **options)
    end

    # Creates an EFT-NP node.
    # 
    # @param nickname [String] nickname for the node
    # @param bank_name [String]
    # @param account_number [String]
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::EftNpNode]
    def create_eft_np_node(**options)
      EftNpNode.create(user: self, **options)
    end

    # Creates an IOU node.
    # 
    # @param nickname [String] nickname for the node
    # @param currency [String] e.g. 'USD'
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::IouNode]
    def create_iou_node(**options)
      IouNode.create(user: self, **options)
    end

    # Creates a RESERVE-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::IouNode]
    def create_reserve_us_node(**options)
      ReserveUsNode.create(user: self, **options)
    end

    # Creates a SYNAPSE-IND node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SynapseIndNode]
    # 
    # @deprecated
    def create_synapse_ind_node(**options)
      SynapseIndNode.create(user: self, **options)
    end

    # Creates a SYNAPSE-NP node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SynapseNpNode]
    def create_synapse_np_node(**options)
      SynapseNpNode.create(user: self, **options)
    end

    # Creates a SYNAPSE-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SynapseUsNode]
    def create_synapse_us_node(**options)
      SynapseUsNode.create(user: self, **options)
    end

    # Creates a DEPOSIT-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SynapseUsNode]
    def create_deposit_us_node(**options)
      DepositUsNode.create(user: self, **options)
    end

    # Creates a SUBACCOUNT-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SubaccountUsNode]
    def create_subaccount_us_node(**options)
      SubaccountUsNode.create(user: self, **options)
    end

    # Creates a TRIUMPH-SUBACCOUNT-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::TriumphSubaccountUsNode]
    def create_triumph_subaccount_us_node(**options)
      TriumphSubaccountUsNode.create(user: self, **options)
    end

    # Creates a WIRE-INT node.
    # 
    # @param nickname [String] nickname for the node
    # @param bank_name [String]
    # @param account_number [String]
    # @param swift [String]
    # @param name_on_account [String]
    # @param address [String]
    # @param routing_number [String] (optional)
    # @param correspondent_bank_name [String] (optional)
    # @param correspondent_routing_number [String] (optional)
    # @param correspondent_address [String] (optional)
    # @param correspondent_swift [String] (optional)
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::WireIntNode]
    def create_wire_int_node(**options)
      WireIntNode.create(user: self, **options)
    end

    # Creates a WIRE-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param bank_name [String]
    # @param account_number [String]
    # @param routing_number [String]
    # @param name_on_account [String]
    # @param address [String]
    # @param correspondent_routing_number [String] (optional)
    # @param correspondent_bank_name [String] (optional)
    # @param correspondent_address [String] (optional)
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::WireUsNode]
    def create_wire_us_node(**options)
      WireUsNode.create(user: self, **options)
    end

    # Creates a CHECK-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param bank_name [String]
    # @param account_number [String]
    # @param routing_number [String]
    # @param name_on_account [String]
    # @param address [String]
    # @param correspondent_routing_number [String] (optional)
    # @param correspondent_bank_name [String] (optional)
    # @param correspondent_address [String] (optional)
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::CheckUsNode]
    def create_check_us_node(**options)
      CheckUsNode.create(user: self, **options)
    end

    # Creates a CLEARING-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::ClearingUsNode]
    def create_clearing_us_node(**options)
      ClearingUsNode.create(user: self, **options)
    end

    # Creates a IB-DEPOSIT-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::IbDepositUsNode]
    def create_ib_deposit_us_node(**options)
      IbDepositUsNode.create(user: self, **options)
    end

    # Creates a IB-SUBACCOUNT-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::IbSubaccountUsNode]
    def create_ib_subaccount_us_node(**options)
      IbSubaccountUsNode.create(user: self, **options)
    end

    # Creates a INTERCHANGE-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param document_id [String] Document ID of user's base document that the card is associated with
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::InterchangeUsNode]
    def create_interchange_us_node(**options)
      InterchangeUsNode.create(user: self, **options)
    end

    # Creates a CARD-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param document_id [String] Document ID of user's base document that the card is associated with
    # @param card_type[String] PHYSICAL or VIRTUAL
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::CardUsNode]
    def create_card_us_node(**options)
      CardUsNode.create(user: self, **options)
    end

    # Creates a SUBCARD-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param document_id [String] Document ID of user's base document that the card is associated with
    # @param card_type[String] PHYSICAL or VIRTUAL
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::SubcardUsNode]
    def create_subcard_us_node(**options)
      SubcardUsNode.create(user: self, **options)
    end

    # Creates a BTC-US node.
    # 
    # @param nickname [String] nickname for the node
    # @param supp_id [String] (optional)
    # @param gateway_restricted [Boolean] (optional)
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::BtcUsNode]
    def create_crypto_us_node(**options)
      CryptoUsNode.create(user: self, **options)
    end


    # Gets statement for user
    # 
    # 
    # @raise [SynapsePayRest::Error]
    # 
    # @return [SynapsePayRest::Statement]

    def get_statement()
      Statement.by_user(client: self.client, user:self)
    end

    # Checks if two User instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end

    private

    # Converts #update args into API payload structure.
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
      payload['update']['remove_legal_name']   = options[:remove_legal_name] if options[:remove_legal_name]
      payload
    end

    def payload_for_refresh
      {'refresh_token' => refresh_token}
    end
  end
end
