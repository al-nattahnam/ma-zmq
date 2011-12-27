module MaZMQ
  class Proxy
    class Balancer
      @@strategies = [
        :round_robin,
        :least_connections,
        :load_balanced, # Cucub podria usar algo como 'less_jobs'
        :priorities,
        :directed
      ]

      def initialize
        self.strategy = :round_robin # default strategy is round_robin
        @index = []
      end
      
      def strategy=(strategy)
        return false if not @@strategies.include? strategy
        @strategy = strategy
      end

      def add(index)
        @index << index
      end

      def current
        @index[0]
      end

      def next
        @index.push(@index.shift)
      end
    end
  end
end
