module SynapsePayRest
  # Represents physical documents that can be added to a base document.
  #
  # @see https://docs.synapsepay.com/docs/user-resources#section-physical-document-types
  #   physical document types
  class PhysicalDocument < Document
    # Converts the document into hash format for use in request JSON.
    # @note You shouldn't need to call this directly.
    #
    # @return [Hash]
    def to_hash
      {'document_value' => to_base64(value), 'document_type' => type}
    end

    private

    # Converts the supplied file to base64 encoding so it can be uploaded to API.
    def to_base64(file_path)
      raise ArgumentError, 'file_path must be a String' unless file_path.is_a?(String)

      content_types = MIME::Types.type_for(file_path)
      file_type = content_types.first.content_type if content_types.any?
      file_contents = open(file_path) { |f| f.read }
      encoded = Base64.encode64(file_contents)
      mime_padding = "data:#{file_type};base64,"
      mime_padding + encoded
    end
  end
end
