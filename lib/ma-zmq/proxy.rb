module MaZMQ
  class Proxy
    include MaZMQ::Proxy::Backend

    #@@id = 0

    def initialize(use_em=true)
      @balancer = MaZMQ::Proxy::Balancer.new

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      super(use_em)
    end

    def send_string(msg)
      @current = current_socket
      return false if @current.is_a? NilClass
      case @current.state
        when :idle
          @current.send_string(msg)
          @balancer.next
        else
          return false
      end
    end

    def connect(protocol, address, port)
      index = super(protocol, address, port)
      @balancer.add(index)
    end

    def disconnect(index)
      @balancer.remove(index)
      super(index)
    end

    def current_socket
      @sockets[@balancer.current]
    end
  end
end
