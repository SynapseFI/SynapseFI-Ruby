module SynapsePayRest
  # this is for social/physical/virtual documents
  class Document
    # TODO: validate category, values, and type based on possible options (different based on whether created or fetched)
    attr_accessor :base_document, :status, :id, :type, :value, :last_updated

    class << self
      def create(type:, value:)
        self.new(type: type, value: value)
      end

      def create_from_response_fields(data)
        self.new(type: data['document_type'], id: data['id'],
          last_updated: data['last_updated'], status: data['status'])
      end
    end

    # TODO: upcase type and validate inputs
    def initialize(**options)
      @type         = options[:type]
      # only exist for created (not for fetched)
      @id           = options[:id]
      @value        = options[:value]
      # must be fetched
      @status       = options[:status]
      @last_updated = options[:last_updated]
    end

    def to_hash
      {'document_value' => value, 'document_type' => type}
    end

    def update_from_response_fields(data)
      self.id           = data['id']
      self.status       = data['status']
      self.last_updated = data['last_updated']
    end
  end
end
