module MaZMQ
  class SocketHandler
    @@protocols = [:tcp, :inproc, :ipc] #, :pgm]

    def initialize
      @socket = MaZMQ::context.socket(@@socket_type)
      build_connection
    end

    def connect(protocol, address, port)
      return false if not MaZMQ::SocketHandler.valid_protocol?(protocol)

      zmq_address = "#{protocol.to_s}://#{address}:#{port.to_s}"
      @socket.connect(zmq_address)
    end

    def send_string(msg)
      @socket.send_string(msg)
    end

    def recv_string
      msg = ''
      @socket.recv_string(msg, ZMQ::NOBLOCK)
      msg
    end

    def socket_type
      @@socket_type
    end

    def on_read(&block)
      return false if block.arity != 1
      @connection.on_read(block)
    end

    def on_write(&block)
      return false if block.arity != 1
      @connection.on_write(block)
    end

    def self.socket_type(socket_type)
      @@socket_type = socket_type
    end


    protected
    def self.valid_protocol?(protocol)
      @@protocols.include? protocol
    end

    private
    def build_connection
      fd = []
      @socket.getsockopt(ZMQ::FD, fd)

      return nil if not ZMQ::Util.resultcode_ok? fd[0]

      @connection = EM.watch(fd[0], MaZMQ::ConnectionHandler, self)
      @connection.notify_readable = true
      @connection.notify_writable = true
      @connection
    end
  end
end
