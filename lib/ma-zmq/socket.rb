module MaZMQ
  class Socket
    @@protocols = [:tcp, :inproc, :ipc] #, :pgm]

    def self.socket_type(socket_type)
      @@socket_type = socket_type
    end

    def initialize()
      @socket = MaZMQ::context.socket(@@socket_type)
      @socket_handler = MaZMQ::SocketHandler.new(@socket)
    end

    def connect(protocol, address, port)
      return false if not MaZMQ::Socket.valid_protocol?(protocol)

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

    def on_read(block)
      return false if block.arity != 1
      @socket_handler.on_read(block)
    end

    def on_write(block)
      return false if block.arity != 1
      @socket_handler.on_write(block)
    end

    protected
    def self.valid_protocol?(protocol)
      @@protocols.include? protocol
    end
  end
end
