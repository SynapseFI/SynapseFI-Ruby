module SynapsePayRest
  class Node
    attr_reader :id, :type

    class << self
      def create(type:, nickname:, **options)
        @type = type
      end
    end
  end
end
