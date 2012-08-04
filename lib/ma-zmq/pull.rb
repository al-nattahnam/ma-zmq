module MaZMQ
  class Pull
    include MaZMQ::SocketHandler

    attr_reader :state

    def initialize
      @socket_type = ZMQ::PULL

      @last_try = nil

      @timeout = false
      # @cooldown

      super
    end

    def recv_string
      if @state == :idle
        @state = :pulling
      end
      case @state
        when :pulling
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
  end
end
