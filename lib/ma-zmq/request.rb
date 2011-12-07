module MaZMQ
  class Request < MaZMQ::Socket
    # mergear con RoundRobin
    socket_type ZMQ::REQ

    def initialize()
      @socket = MaZMQ::context.socket(@@socket_type)
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
  end
end
