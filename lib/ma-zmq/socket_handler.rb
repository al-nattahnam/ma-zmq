module MaZMQ
  class SocketHandler
    def initialize(socket)
      @socket = socket

      @connection = build_connection
      @connection.notify_readable = true
      @connection.notify_writable = true
    end

    def on_read(block)
      return false if block.arity != 1
      @connection.on_read(block)
    end

    def on_write(block)
      return false if block.arity != 1
      @connection.on_write(block)
    end

    def socket_type
      @socket.socket_type
    end

    private
    def build_connection
      fd = []
      @socket.getsockopt(ZMQ::FD, fd)
      return nil if not ZMQ::Util.resultcode_ok? fd[0]
      EM.watch(fd[0], MaZMQ::ConnectionHandler, self)
    end
  end
end
