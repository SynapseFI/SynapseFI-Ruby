# Basic wrapper around the the requests library.
require_relative "synapse_pay_rest/http_client"
# Assign all the api classes
require_relative "synapse_pay_rest/api/User"
require_relative "synapse_pay_rest/api/Node"
require_relative "synapse_pay_rest/api/Trans"

module SynapsePayRest
	class SynapsePayClient

		attr_accessor :client
		attr_accessor :user
		attr_accessor :node
		attr_accessor :trans

		def initialize(options: , user_id: nil)
			base_url = 'https://synapsepay.com/api/3'
			if options.has_key?('is_development')
				if options['is_development']
					base_url = 'https://sandbox.synapsepay.com/api/3'
				end
			end

			@client = HTTPClient.new options, base_url, user_id: user_id
			@user = User.new @client
			@node = Node.new @client
			@trans = Trans.new @client
		end
	end
end
