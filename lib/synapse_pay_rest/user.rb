module SynapsePayRest
  class User
    # could do these dynamically but this is probably more readable
    # TODO: Login class? Document class?
    attr_reader :client, :logins, :phone_numbers, 
                :legal_names, :note, :supp_id, :is_business, :cip_tag
    attr_accessor :id

    class << self
      def find(client:, id:)
        response = client.users.get(user_id: id)
        User.new(
          client: client, 
          id: response['_id'], 
          logins: response['logins'], 
          phone_numbers: response['phone_numbers']
        )
      end

      # TODO: cache response and have some parameter for force re-fetch
      def all(client:, page: 1, per_page: 15)
        response = client.users.get(options: {page: page, per_page: per_page})
        response['users'].map do |data|
          args = {
            client: client,
            logins: data['logins'],
            phone_numbers: data['phone_numbers'],
            legal_names: data['legal_names'],
            supp_id: data['extra']['supp_id'],
            is_business: data['extra']['is_business'],
            cip_tag: data['extra']['cip_tag']
          }
          user = User.new(args)
          user.id = data['_id']
          user
        end
      end
    end

    # provide id for existing user or required fields for new user
    # TODO: handle error if id not found
    def initialize(client:, id: nil, **user_fields)
      @id = id
      @client = client
      validate_minimal_initalization_args(user_fields)

      if id
        fetch_info(id: id)
      else
        client.users.create(payload: user_fields)
        # generate instance variables for each key in user_fields
        user_fields.each { |key, value| instance_variable_set("@#{key}", value) }
      end
    end

    def update
    end

    # def create_node(node)
    #   @nodes << node
    # end

    # def nodes
    # end

    private

    # TODO: validate format of each arg as well
    # TODO: allow email/password in lieue of logins array
    def validate_minimal_initalization_args(args)
      if id.nil?
        required_params = [:logins, :phone_numbers, :legal_names]
        required_params.each do |arg|
          unless args[arg]
            raise ArgumentError, "must initialize #{self.class} with either id or #{required_params.join('/')}"
            raise ArgumentError, "#{arg} must be an array"
          end
        end
      end
    end

    # def add_login(email:, password: nil)
    # end

    # TODO: assign all data from response to instance methods (iterating through and creating documents, etc)
    def fetch_info(id:)
      data = client.users.get(user_id: ENV.fetch('USER_ID'))
      @logins = data['logins']
      @phone_numbers = data['phone_numbers']
      @legal_names = data['legal_names']
      @supp_id = data['extra']['supp_id']
      @is_business = data['extra']['is_business']
      @cip_tag = data['extra']['cip_tag']
    end
  end
end
