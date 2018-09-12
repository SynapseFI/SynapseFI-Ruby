module SynapsePayRest
  # Represents a public key record and holds methods for getting public key instances
  # from API calls. This is built on top of the SynapsePayRest::Client class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  class Atm 
    attr_reader :client, :address_city, :address_country, :address_postal_code, :address_state, :address_street,
    :latitude, :longitude, :id, :isAvailable24Hours, :isDepositAvailable, :isHandicappedAccessible, :isOffPremise,
    :isSeasonal, :languageType, :locationDescription, :logoName, :name, :distance

    class << self
      # Creates a client public key from a response hash.
      # @note Shouldn't need to call this directly.
      def from_response(client, response)
        args = {
          client:                  client,
          address_city:            response['atmLocation']['address']['city'],
          address_country:         response['atmLocation']['address']['country'],
          address_postal_code:     response['atmLocation']['address']['postalCode'],
          address_state:           response['atmLocation']['address']['state'],
          address_street:          response['atmLocation']['address']['street'],
          latitude:                response['atmLocation']['coordinates']['latitude'],
          longitude:               response['atmLocation']['coordinates']['longitude'],
          id:                      response['atmLocation']['id'],
          isAvailable24Hours:      response['atmLocation']['isAvailable24Hours'],
          isDepositAvailable:      response['atmLocation']['isDepositAvailable'],
          isHandicappedAccessible: response['atmLocation']['isHandicappedAccessible'],
          isOffPremise:            response['atmLocation']['isOffPremise'],
          isSeasonal:              response['atmLocation']['isSeasonal'],
          languageType:            response['atmLocation']['languageType'],
          locationDescription:     response['atmLocation']['locationDescription'],
          logoName:                response['atmLocation']['logoName'],
          name:                    response['atmLocation']['name'],
          distance:                response['distance']
        }
        self.new(args)
      end

      # Locate ATMs near zip code
      # @param client [SynapsePayRest::Client]
      # @param zip [String]
      # 
      # @raise [SynapsePayRest::Error]
      # 
      # @return [SynapsePayRest::Atm] new instance corresponding to same API record
      def locate(client:, zip: nil, page: nil, per_page: nil, radius: nil, lat: nil, lon: nil)
        raise ArgumentError, 'client must be a SynapsePayRest::Client' unless client.is_a?(Client)
        [page, per_page].each do |arg|
          if arg && (!arg.is_a?(Integer) || arg < 1)
            raise ArgumentError, "#{arg} must be nil or an Integer >= 1"
          end
        end

        [zip, radius, lat, lon].each do |arg|
          if arg && !arg.is_a?(String)
            raise ArgumentError, "#{arg}must be a String"
          end
        end

        response = client.atms.locate(zip: zip, page: page, per_page: per_page, radius: radius, lat: lat, lon: lon)
        multiple_from_response(client, response['atms'])
      end


      # Calls from_response on each member of a response collection.
      def multiple_from_response(client, response)
        return [] if response.empty?
        response.map { |atm_data| from_response(client.dup, atm_data)}
      end
    end


    # @note Do not call directly. Use other class method
    #   to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end


  end
end