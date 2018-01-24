module SynapsePayRest
  # This node allows you to send a check to any individual or entity in the US.
  #Currently in sandbox only.
  class CheckUsNode < BaseNode
    class << self
      private

      def payload_for_create(nickname:, payee_name:, address_street:, address_city:,
        address_subdivision:, address_country_code:, address_postal_code:, **options)
        args = {
          type: 'CHECK-US',
          nickname: nickname,
          payee_name: payee_name,
          address_street: address_street,
          address_city: address_city,
          address_subdivision: address_subdivision,
          address_country_code: address_country_code,
          address_postal_code: address_postal_code
        }.merge(options)
        super(args)
      end
    end
  end
end

