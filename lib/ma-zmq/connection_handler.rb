module MaZMQ
  class ConnectionHandler < EM::Connection
    def initialize(socket_handler)
      @socket_handler = socket_handler

      @on_read_lambda = lambda {|m|}
      @on_write_lambda = lambda {|m|}
      @on_timeout_lambda = lambda {}
    end

    def on_read(block)
      @on_read_lambda = block
    end

    def on_write(block)
      @on_write_lambda = block
    end

    def on_timeout(block)
      @on_timeout_lambda = block
    end

    def notify_readable
      if @socket_handler.socket_type == ZMQ::REP
        msg = try_read
        if msg
          @on_read_lambda.call(msg)
        end
      end
    end

    def notify_writable
      if @socket_handler.socket_type == ZMQ::REQ or @socket_handler.socket_type == ZMQ::REP
        msg = try_read
        if msg
          @on_read_lambda.call(msg)
        else
          if @socket_handler.socket_type == ZMQ::REQ and @socket_handler.state == :timeout
            @on_timeout_lambda.call
            @socket_handler.idle!
          end
        end
      end
    end

    def try_read
      msg = @socket_handler.recv_string
      if msg and not msg.empty?
        return msg
      else
        return false
      end
    end
  end
end
