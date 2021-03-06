module MaZMQ
  class Proxy
    include MaZMQ::Proxy::Backend

    #@@id = 0

    def initialize
      @balancer = MaZMQ::Proxy::Balancer.new

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      super
    end

    def send_string(msg)
      @current = current_socket
      return false if @current.is_a? NilClass
      case @current.state
        when :idle
          @current.send_string(msg)
        else
          return false
      end
      @balancer.next
    end

    def connect(protocol, address, port)
      return false if addresses.include? "#{protocol}://#{address}:#{port.to_s}"
      index = super(protocol, address, port)
      #@balancer.curent refresh ! TODO
      @balancer.add(index)
      index
    end

    def disconnect(index)
      @balancer.remove(index)
      super(index)
    end

    def close
      @sockets.each do |s|
        s.close
      end
    end

    def addresses
      @sockets.collect{|s| s.addresses}.flatten
    end

    def current_socket
      @sockets[@balancer.current]
    end
  end
end
