require 'open-uri'

module SynapsePayRest
  # Represents physical documents that can be added to a base document.
  #
  # @see https://docs.synapsepay.com/docs/user-resources#section-physical-document-types
  #   physical document types
  class PhysicalDocument < Document

    class << self
      # Creates a document instance but does not submit it to the API. Use
      # BaseDocument#create/#update/#add_physical_documents or related methods
      # to submit the document to the API.
      #
      # @note This should only be called on subclasses of Document, not on
      #   Document itself.
      #
      # @param type [String]
      # @param value [String] (optional) padded base64-encoded image ("data:#{mime_type};base64,#{base64}")
      # @param file_path [String] (optional) path to image file
      # @param url [String] (optional) image file url
      # @param byte_stream [String] (optional) byte representation of image
      # @param mime_type [String] (optional) mime type of byte_stream (e.g. 'image/png')
      #
      # @return [SynapsePayRest::Document]
      #
      # @see https://docs.synapsepay.com/docs/user-resources#section-physical-document-types physical document types
      # @see https://docs.synapsepay.com/docs/user-resources#section-social-document-types social document types
      # @see https://docs.synapsepay.com/docs/user-resources#section-virtual-document-types virtual document types
      def create(type:, **options)
        if options[:file_path]
          value = self.file_to_base64(options[:file_path])
        elsif options[:url]
          value = self.url_to_base64(options[:url])
        elsif options[:byte_stream]
          value = self.byte_stream_to_base64(options[:byte_stream], options[:mime_type])
        elsif options[:value]
          value = options[:value]
        end

        super(type: type, value: value)
      end

      # Converts the supplied image url to padded base64
      def url_to_base64(url)
        raise ArgumentError, 'url must be a String' unless url.is_a?(String)
        byte_stream = open(url).read
        begin
          # remove any query params to get the mime type
          mime_type = MIME::Types.type_for(url.gsub(/\?.*$/, '')).first.content_type
        rescue
          mime_type = nil
        end
        byte_stream_to_base64(byte_stream, mime_type)
      end

      # Converts the supplied image file to padded base64
      def file_to_base64(file_path)
        raise ArgumentError, 'file_path must be a String' unless file_path.is_a?(String)
        url_to_base64(file_path)
      end

      # Converts the supplied image byte stream to padded base64
      def byte_stream_to_base64(byte_stream, mime_type)
        base64 = Base64.encode64(byte_stream)
        "data:#{mime_type};base64,#{base64}"
      end
    end
  end
end
