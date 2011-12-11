module MaZMQ
  class LoadBalancer
    # Aprovechar el tiempo de timeout para seguir mandando a los restantes

    def initialize(use_em=true)
      @current_message = nil
      @use_em = use_em

      @sockets = []
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

      @current ||= available
    end

    def timeout(secs)
      @timeout = secs
      @sockets.each do |s|
        s.timeout @timeout
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
        when :idle then false
        when :sending then @current.recv_string
        when :timeout then false
      end

      # chequear @use_em = false
      #if @timeout and @current.state == :timeout
      #  rotate!
      #  @state = :retry
      #  @current.send_string @current_message
      #  return false
      #end
      return msg
    end

    def on_timeout(&block)  
      return false if not @use_em
      @sockets.each do |socket|
        socket.on_timeout {
          self.rotate!(true)
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
    end
  end
end
