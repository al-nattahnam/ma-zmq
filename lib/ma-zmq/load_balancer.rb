module MaZMQ
  class LoadBalancer
    # Aprovechar el tiempo de timeout para seguir mandando a los restantes

    def initialize(use_em=true)
      # [] rr.connect('tcp://127.0.0.1')
      # only REQ / REP pattern

      @current_message = nil
      @use_em = use_em
      #@handler = MaZMQ::HandlerPool.new(ports, @use_em)

      @sockets = []
      #ports.each do |port|
      #  socket = MaZMQ::Request.new(use_em) # TODO debugging only
      #end

      @current = available

      @timeout = nil # TODO individual timeouts for different sockets
      @state = :idle

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries
    end

    def connect(protocol, address, port)
      # validate as in SocketHandler
      request = MaZMQ::Request.new(@use_em)
      request.connect(protocol, address, port)
      @sockets << request
    end

    def timeout(secs)
      @timeout = secs
      #@handler.timeout(secs)
      @sockets.each do |s|
        s.timeout secs
      end
    end

    def send_string(msg)
      case @state
        when :idle
          @current_message = msg
          @state = :sending
          @current.send_string(@current_message)
        when :retry
          @state = :sending
          @current.send_string(@current_message)
        when :sending
          return false
      end
    end

    def recv_string
      msg = case @current.state
        when :sending then @current.recv_string
        when :idle, :timeout then false
      end

      #msg = @handler.recv_string
      if @timeout and @current.state == :timeout
        #@handler.rotate!
        rotate!
        @state = :retry
        @current.send_string @current_message
        return false
      end
      return msg
    end

    def on_timeout(&block)  
      return false if not @use_em
      @sockets.each do |socket|
        socket.on_timeout {
          self.rotate!
          @state = :retry
          self.send_string @current_message
          block.call
        }
      end
    end

    def on_read(&block)
      return false if not @use_em
      @sockets.each do |socket|
        socket.on_read { |msg|
          self.rotate!
          @state = :idle
          block.call(msg)
        }
      end
    end

    def available
      @sockets.select{|s| s.state == :idle}.first
    end

    def rotate!(timeout=false)
      #@sockets.delete_at(0)
      @sockets.push(@sockets.shift)
      if timeout
        @sockets.delete_at(-1)
      end
  
      @current = available
      #@state = :idle
    end
  end
end
