module SynapsePayRest
  class Transactions
    # TODO: Should refactor this to HTTPClient
    VALID_QUERY_PARAMS = [:page, :per_page].freeze

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def create(node_id: raise('node_id is required'), payload: raise('payload is required'))
      path = create_transaction_path(node_id: node_id)
      client.post(path, payload)
    end

    def update(node_id: raise('node_id is required'), trans_id: raise('trans_id is required'), payload: raise('payload is required'))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.patch(path, payload)
    end

    # if trans_id is nil then returns all transactions
    def get(node_id: raise('node_id is required'), trans_id: nil, **options)
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)

      # TODO: Should factor this out into HTTPClient and separate args for paginate/search(name/email)/per_page
      params = VALID_QUERY_PARAMS.map do |p|
        options[p] ? "#{p}=#{options[p]}" : nil
      end.compact

      # TODO: Probably should use CGI or RestClient's param builder instead of
      # rolling our own, probably error-prone and untested version
      # https://github.com/rest-client/rest-client#usage-raw-url
      path += '?' + params.join('&') if params.any?
      client.get(path)
    end

    def delete(node_id: raise('node_id is required'), trans_id: raise('trans_id is required'))
      path = create_transaction_path(node_id: node_id, trans_id: trans_id)
      client.delete(path)
    end

    private

    def create_transaction_path(node_id: raise('node_id is required'), trans_id: nil)
      path = ['/users', client.user_id, 'nodes', node_id, 'trans' ]
      path << trans_id if trans_id
      return path.join('/')
    end
  end
end
