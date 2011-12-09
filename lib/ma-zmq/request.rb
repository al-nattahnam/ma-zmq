module MaZMQ
  class Request < MaZMQ::SocketHandler
    # mergear con RoundRobin
    #socket_type ZMQ::REQ

    def initialize(use_eventmachine=true)
      @socket_type = ZMQ::REQ

      @state = :idle
      @last_try = nil

      @timeout = false
      # @cooldown
      super(use_eventmachine)
    end

    def send_string(msg)
      case @state
        when :idle
          super(msg)
          @state = :sending
          return @state
        else
          return false
      end
    end

    def recv_string
      case @state
        when :idle
          return false
        when :sending
          @last_try ||= Time.now if @timeout

          msg = super

          if msg.empty?
            if @timeout and (Time.now - @last_try) > @timeout
              @state = :timeout
            end
          else
            @last_try = nil if @timeout
            @state = :idle
          end
          return msg
        when :timeout
          return false
      end
    end

    def timeout(secs)
      @timeout = secs
    end

    def on_timeout(&block)
      return false if not @connection or block.arity != -1
      @connection.on_timeout(block)
    end

    def idle!
      # count timeouts, timeouts available before :error
      @state = :idle
    end

    def state
      @state
    end
  end
end
