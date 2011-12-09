module MaZMQ
  class RoundRobin
    # Aprovechar el tiempo de timeout para seguir mandando a los restantes

    def initialize(ports=[], use_em=true)
      # [] rr.connect('tcp://127.0.0.1')
      # only REQ / REP pattern

      @current_message = nil
      @use_em = use_em
      @handler = MaZMQ::HandlerPool.new(ports, @use_em)

      @timeout = nil # TODO individual timeouts for different sockets
      @state = :idle
    end

    def timeout(secs)
      @timeout = secs
      @handler.timeout(secs)
    end

    def send_string(msg)
      case @state
        when :idle
          @current_message = msg
          @state = :sending
          @handler.send_string(@current_message)
        when :retry
          @state = :sending
          @handler.send_string(@current_message)
        when :sending
          return false
      end
    end

    def recv_string
      msg = @handler.recv_string
      if @timeout and @handler.state == :timeout
        @handler.rotate!
        @state = :retry
        @handler.send_string @current_message
        return false
      end
      return msg
    end

    def on_timeout(&block)
      @handler.on_timeout do
        @handler.rotate!
        @state = :retry
        @handler.send_string @current_message
        block.call
      end
    end

    def on_read(&block)
      @handler.on_read{ |msg|
        @handler.rotate!
        @state = :idle
        block.call(msg)
      }
    end
  end
end
