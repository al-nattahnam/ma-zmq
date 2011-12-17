module MaZMQ
  class Reply < MaZMQ::SocketHandler
    attr_reader :state

    def initialize(use_eventmachine=true)
      @socket_type = ZMQ::REP
      super(use_eventmachine)
    end

    def recv_string
      case @state
        when :idle
          msg = super
          if msg and not msg.empty?
            @state = :reply
          end
          return msg
        else
          return false
      end
    end

    def send_string(msg)
      case @state
        when :reply
          resp = super(msg)
          @state = :idle
          return resp
        else
          return false
      end
    end
  end
end
