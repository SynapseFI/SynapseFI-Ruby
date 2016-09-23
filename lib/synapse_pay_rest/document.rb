module SynapsePayRest
  # this is for social/physical/virtual documents
  class Document
    # TODO: validate category, values, and type based on possible options (different based on whether created or fetched)
    attr_accessor :cip_document, :status, :id, :type, :value

    class << self
      def create(type:, value:)
        self.new(type: type, value: value)
      end

      def create_from_response(response)
      end
    end

    # TODO: upcase type and validate inputs
    def initialize(**options)
      @type   = options[:type]
      # only exist for created (not for fetched)
      @id     = options[:id]
      @value  = options[:value]
      # must be fetched
      @status = options[:status]
    end

    def to_hash
      {'document_value' => value, 'document_type' => type}
    end

    def update_with_response_data(response_data)
    end
  end
end
