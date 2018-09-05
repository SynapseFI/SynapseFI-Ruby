module SynapsePayRest
  # Custom class for handling HTTP and API errors.
  class Error < StandardError
    # Raised on a 4xx HTTP status code
    ClientError = Class.new(self)

    # Raised on the HTTP status code 400
    BadRequest = Class.new(ClientError)

    # Raised on the HTTP status code 401
    Unauthorized = Class.new(ClientError)

    # Raised on the HTTP status code 402
    RequestDeclined = Class.new(ClientError)

    # Raised on the HTTP status code 403
    Forbidden = Class.new(ClientError)

    # Raised on the HTTP status code 404
    NotFound = Class.new(ClientError)

    # Raised on the HTTP status code 406
    NotAcceptable = Class.new(ClientError)

    # Raised on the HTTP status code 409
    Conflict = Class.new(ClientError)

    # Raised on the HTTP status code 415
    UnsupportedMediaType = Class.new(ClientError)

    # Raised on the HTTP status code 422
    UnprocessableEntity = Class.new(ClientError)

    # Raised on the HTTP status code 429
    TooManyRequests = Class.new(ClientError)

    # Raised on a 5xx HTTP status code
    ServerError = Class.new(self)

    # Raised on the HTTP status code 500
    InternalServerError = Class.new(ServerError)

    # Raised on the HTTP status code 502
    BadGateway = Class.new(ServerError)

    # Raised on the HTTP status code 503
    ServiceUnavailable = Class.new(ServerError)

    # Raised on the HTTP status code 504
    GatewayTimeout = Class.new(ServerError)

    # HTTP status code to Error subclass mapping
    #
    # @todo need to add an error message for various 202 cases (fingerprint, mfa, etc)
    # @todo doesn't do well when there's an html response from nginx for bad gateway/timeout
    ERRORS = {
      '400' => SynapsePayRest::Error::BadRequest,
      '401' => SynapsePayRest::Error::Unauthorized,
      '402' => SynapsePayRest::Error::RequestDeclined,
      '403' => SynapsePayRest::Error::Forbidden,
      '404' => SynapsePayRest::Error::NotFound,
      '406' => SynapsePayRest::Error::NotAcceptable,
      '409' => SynapsePayRest::Error::Conflict,
      '415' => SynapsePayRest::Error::UnsupportedMediaType,
      '422' => SynapsePayRest::Error::UnprocessableEntity,
      '429' => SynapsePayRest::Error::TooManyRequests,
      '500' => SynapsePayRest::Error::InternalServerError,
      '502' => SynapsePayRest::Error::BadGateway,
      '503' => SynapsePayRest::Error::ServiceUnavailable,
      '504' => SynapsePayRest::Error::GatewayTimeout
    }.freeze

    # The SynapsePay API Error Code
    #
    # @return [Integer]
    attr_reader :code

    # The JSON HTTP response in Hash form
    #
    # @return [Hash]
    attr_reader :response

    class << self
      # Create a new error from an HTTP response
      #
      # @param body [String]
      # @param code [Integer]
      # @return [SynapsePayRest::Error]
      def from_response(body)
        message, error_code, http_code = parse_error(body)
        http_code = http_code.to_s
        klass = ERRORS[http_code] || SynapsePayRest::Error
        klass.new(message: message, code: error_code, response: body)
      end

      private

      def parse_error(body)
        if body.nil? || body.empty?
          ['', nil, nil]
        elsif body.is_a?(Hash) && body['error'].is_a?(Hash)
          [body['error']['en'], body['error_code'], body['http_code']]
        elsif body.is_a?(Hash) && body[:error].is_a?(Hash)
          [body[:error][:en], body[:error_code], body[:http_code]]
        end
      end
    end

    # Initializes a new Error object
    #
    # @param message [Exception, String]
    # @param code [Integer]
    # @param response [Hash]
    # @return [SynapsePayRest::Error]
    def initialize(message: '', code: nil, response: {})
      super(message)
      @code     = code
      @response = response
    end
  end
end
