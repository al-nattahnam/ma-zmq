module MaZMQ
  class ConnectionHandler < EM::Connection
    def initialize(socket_handler)
      @socket_handler = socket_handler
      @socket_type = socket_handler.socket_type

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
      #if @socket_handler.socket_type == ZMQ::REP
      #  if @socket_handler.state == :idle
      #    msg = try_read
      #    if msg
      #      @on_read_lambda.call(msg)
      #    end
      #  end
      #end
    end

    def notify_writable
      case @socket_type
        when ZMQ::REP
          if @socket_handler.state == :idle
            msg = @socket_handler.recv_string
            if msg and not msg.empty?
              @on_read_lambda.call(msg)
            end
          end
        when ZMQ::REQ
          if @socket_handler.state == :sending
            msg = @socket_handler.recv_string
          end
          case @socket_handler.state
            when :idle
              if msg and not msg.empty?
                @on_read_lambda.call(msg)
              end
            when :timeout
              @on_timeout_lambda.call #(@socket_handler.identity)
              puts "SocketHandler: #{@socket_handler.identity} timeout!"
              self.detach
          end
      end
    end
  end
end
