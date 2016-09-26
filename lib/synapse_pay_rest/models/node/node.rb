module SynapsePayRest
  class Node
    attr_reader :id, :type

    def initialize(type:)
      @type = type
    end
  end
end
