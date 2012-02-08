module MaZMQ
  class SocketHandler
    @@protocols = [:tcp, :inproc, :ipc] #, :pgm]

    def initialize(use_eventmachine=true)
      @socket = MaZMQ::context.socket(@socket_type)
      @addresses = []
      if use_eventmachine
        build_connection
      else
        @connection = false
      end
      @recv_flags = (use_eventmachine ? ZMQ::NOBLOCK : 0)
      
      @state = :unavailable
    end

    def connect(protocol, address, port=nil)
      # check multiple connects for ZMQ::REQ should RoundRobin
      zmq_address = MaZMQ::SocketHandler.valid_address(protocol, address, port)
      return false if not zmq_address.is_a? String

      @socket.connect(zmq_address)

      @addresses << zmq_address
      
      if @state == :unavailable
        @state = :idle
      end
      @state
    end

    def bind(protocol, address, port=nil)
      # check once binded should not bind anymore
      zmq_address = MaZMQ::SocketHandler.valid_address(protocol, address, port)
      return false if not zmq_address.is_a? String

      @socket.bind(zmq_address)

      @addresses << zmq_address

      if @state == :unavailable
        @state = :idle
      end
      @state
    end

    def close
      @socket.close
      #if use_eventmachine
      #  @connection.detach
      #end
    end

    def addresses
      @addresses
    end

    def send_string(msg)
      @socket.send_string(msg)
    end

    def recv_string#(flags=nil)
      msg = ''
      @socket.recv_string(msg, @recv_flags)
      return msg
    end

    def socket_type
      @socket_type
    end

    def on_read(&block)
      return false if not @connection or block.arity != 1
      @connection.on_read(block)
    end

    def on_write(&block)
      return false if not @connection or block.arity != 1
      @connection.on_write(block)
    end

    def identity
      arr = []
      @socket.getsockopt(ZMQ::IDENTITY, arr)
      arr[0].to_sym rescue nil
    end

    def identity=(identity)
      @socket.setsockopt(ZMQ::IDENTITY, identity.to_s)
    end

    protected
    def self.valid_address(protocol, address, port=nil)
      case protocol
        when :tcp
          if port.is_a? Numeric
            return "#{protocol}://#{address}:#{port.to_s}"
          else
            return false
          end
        when :ipc
          # Chequear socket file
          if port.is_a? NilClass
            return "#{protocol}://#{address}"
          else
            return false
          end
        when :inproc
          if port.is_a? NilClass
            return "#{protocol}://#{address}"
          else
            return false
          end
      end
    end

    def self.valid_protocol?(protocol)
      @@protocols.include? protocol
    end
    
    private
    def build_connection
      fd = []
      @socket.getsockopt(ZMQ::FD, fd)

      return nil if not ZMQ::Util.resultcode_ok? fd[0]

      @connection = EM.watch(fd[0], MaZMQ::ConnectionHandler, self)
      #@connection.notify_readable = true
      @connection.notify_writable = true
      @connection
    end
  end
end
