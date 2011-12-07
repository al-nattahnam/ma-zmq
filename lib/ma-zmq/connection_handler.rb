module MaZMQ
  class ConnectionHandler < EM::Connection
    def initialize(socket)
      @socket = socket
      @on_read_lambda = lambda {|m|}
      @on_write_lambda = lambda {|m|}
    end

    def on_read(block)
      @on_read_lambda = block
    end

    def on_write(&block)
      @on_write_lambda = block
    end

    def notify_readable
      if @socket.socket_type == ZMQ::REP
        msg = try_read
        if msg
          @on_read_lambda.call(msg)
        end
      end
    end

    def notify_writable
      if @socket.socket_type == ZMQ::REQ
        msg = try_read
        if msg
          @on_write_lambda.call(msg)
        end
      end
    end

    def try_read
      msg = @socket.recv_string
      if msg.empty?
        return false
      else
        return msg
      end
    end
  end
end
