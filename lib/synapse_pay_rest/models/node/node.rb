module SynapsePayRest
  class Node
    # TODO: this seems janky but there is a circular dep otherwise w/ the current implementation
    # TODO: check out how it's done in error.rb
    require 'synapse_pay_rest/models/node/synapse_node'
    require 'synapse_pay_rest/models/node/synapse_us_node.rb'
    require 'synapse_pay_rest/models/node/synapse_ind_node.rb'
    require 'synapse_pay_rest/models/node/synapse_np_node.rb'
    require 'synapse_pay_rest/models/node/unverified_node.rb'
    require 'synapse_pay_rest/models/node/ach_us_node.rb'
    require 'synapse_pay_rest/models/node/eft_node'
    require 'synapse_pay_rest/models/node/eft_ind_node.rb'
    require 'synapse_pay_rest/models/node/eft_np_node.rb'
    require 'synapse_pay_rest/models/node/wire_node.rb'
    require 'synapse_pay_rest/models/node/wire_us_node.rb'
    require 'synapse_pay_rest/models/node/wire_int_node.rb'
    require 'synapse_pay_rest/models/node/reserve_us_node.rb'
    require 'synapse_pay_rest/models/node/iou_node.rb'

    attr_reader :user, :id, :nickname, :supp_id, :currency, :is_active, :permissions,
                :account_number, :routing_number, :name_on_account, :address,
                :bank_name, :bank_id, :bank_pw, :account_class, :account_type,
                :correspondent_routing_number, :correspondent_bank_name,
                :correspondent_address, :correspondent_swift, :account_id, :balance,
                :ifsc, :swift, :bank_long_name

    NODE_TYPES_TO_CLASSES = {
      'ACH-US'      => SynapsePayRest::AchUsNode,
      'EFT-NP'      => SynapsePayRest::EftNpNode,
      'EFT-IND'     => SynapsePayRest::EftIndNode,
      'IOU'         => SynapsePayRest::IouNode,
      'RESERVE-US'  => SynapsePayRest::ReserveUsNode,
      'SYNAPSE-IND' => SynapsePayRest::SynapseIndNode,
      'SYNAPSE-NP'  => SynapsePayRest::SynapseNpNode,
      'SYNAPSE-US'  => SynapsePayRest::SynapseUsNode,
      'WIRE-INT'    => SynapsePayRest::WireIntNode,
      'WIRE-US'     => SynapsePayRest::WireUsNode
    }

    class << self
      def create(user:, nickname:, **options)
        payload = payload_for_create(nickname: nickname, **options)
        user.authenticate
        response = user.client.nodes.add(payload: payload)
        create_from_response(user, response)
      end

      def find(user:, id:)
        response = user.client.get(user_id: user.id)
        create_from_response(user, response)
      end

      # TODO: validate arguments in valid range / type options
      def all(user:, page: 1, per_page: 20, type: nil)
        response = user.client.nodes.get(page: page, per_page: per_page, type: type)
        return [] if response['nodes'].empty?

        response['nodes'].map { |data| create_from_response(user, data)}
      end

      def by_type(user:, type:, page: 1, per_page: 20)
        all(user: user, page: page, per_page: per_page, type: type)
      end

      private

      def create_from_response(user, response)
        node_class = NODE_TYPES_TO_CLASSES[response['type']]
        node_class.create_from_response(user, response)
      end
    end

    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def destroy
      response = client.nodes.delete(node_id: id)
      if response['success']
        user.client.nodes.delete(self)
      else
        # TODO: handle error
      end
    end
  end
end
