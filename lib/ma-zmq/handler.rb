module MaZMQ
  class Handler < EM::Connection
    def initialize(socket)
      @socket = socket
    end

    def notify_readable
      if @socket.socket_type == ZMQ::REP
        try_read
      end
    end

    def notify_writable
      if @socket.socket_type == ZMQ::REQ
        try_read
      end
    end

    def try_read
      msg = @socket.recv_string
      if not msg.empty?
        puts msg
      end
    end
  end
end
