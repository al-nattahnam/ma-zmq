module MaZMQ
  class Proxy
    class Balancer
      @@strategies = [
        :round_robin,
        :connections,
        :load, # Cucub podria usar algo como 'less_jobs'
        :priority,
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

      def remove(index)
        @index.delete(index)
      end

      def current
        @index[0]
      end

      def next
        case @strategy
          when :round_robin
            @index.push(@index.shift)
        end
      end
    end
  end
end
