module SynapsePayRest
  class PhysicalDocument < Document
    def to_hash
      {'document_value' => to_base64(value), 'document_type' => type}
    end

    private

    def to_base64(file_path)
      content_types = MIME::Types.type_for(file_path)
      file_type = content_types.first.content_type if content_types.any?
      file_contents = open(file_path) { |f| f.read }
      encoded = Base64.encode64(file_contents)
      mime_padding = "data:#{file_type};base64,"
      mime_padding + encoded
    end
  end
end
