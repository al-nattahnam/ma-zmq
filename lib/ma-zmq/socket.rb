module MaZMQ
  class Socket
    @@protocols = [:tcp, :inproc, :ipc] #, :pgm]

    def self.socket_type(socket_type)
      @@socket_type = socket_type
    end

    def initialize()
      @socket = MaZMQ::context.socket(@@socket_type)

      @connection = build_em_connection
      @connection.notify_readable = true
      #@em_handler = bla
    end

    def build_em_connection
      fd = []
      @socket.getsockopt(ZMQ::FD, fd)
      return nil if not ZMQ::Util.resultcode_ok? fd[0]
      EM.watch(fd[0], MaZMQ::Handler.new)
    end

    def notify_readable
      recv_string
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
      @socket.recv_string(msg)
      msg
    end

    def on_read(&block)
      #OwnHandler.pass(&block)
    end

    def on_write(&block)
      #OwnHandler.pass(&block)
    end

    protected
    def self.valid_protocol?(protocol)
      @@protocols.include? protocol
    end
  end
end
