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

      def current_index
        @index[0]
      end

      def next_index
        @index.push(@index.shift)
      end
    end
  end
end
