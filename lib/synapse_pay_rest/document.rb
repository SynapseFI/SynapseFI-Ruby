module SynapsePayRest
  # this is for social/physical/virtual documents
  class Document
    # TODO: validate category, values, and type based on possible options (different based on whether created or fetched)
    attr_reader :category, :type, :value, :status, :id
    attr_accessor :cip_document

    def initialize(**options)
      @category = options[:category]
      @type     = options[:type]
      @value    = options[:value]
      @status   = options[:status]
    end
  end
end
