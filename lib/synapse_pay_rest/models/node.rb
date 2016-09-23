module SynapsePayRest
  class Node
    attr_reader :node_id, :type

    def initialize(type:)
      @type = type
    end
  end
end
