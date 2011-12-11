module MaZMQ
  class LoadBalancer
    # Aprovechar el tiempo de timeout para seguir mandando a los restantes
    # roundrobin
    # leastconnections
    # directed
    # priorities

    # Split LoadBalancer / Backend

    def initialize(use_em=true)
      @current_message = nil
      @use_em = use_em

      @sockets = []
      #@current = available

      @timeout = nil # TODO individual timeouts for different sockets
      @state = :idle

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      # load_balancer itself
      @on_timeout_lambda = lambda {}
      @on_read_lambda = lambda {|m|}
    end

    def connect(protocol, address, port)
      # validate as in SocketHandler
      request = MaZMQ::Request.new(@use_em)
      request.connect(protocol, address, port)
      if @use_em
        request.timeout(@timeout)
        request.on_read { |msg|
          @on_read_lambda.call(msg)
        }
        request.on_timeout {
          @on_timeout_lambda.call
        }
      end
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
      @on_timeout_lambda = lambda {
        self.rotate!(true)
        @state = :retry
        self.send_string @current_message
        block.call
      }
      @sockets.each do |socket|
        socket.on_timeout {
          @on_timeout_lambda.call
          #self.rotate!(true)
          #@state = :retry
          #self.send_string @current_message
          #block.call
        }
      end
    end

    def on_read(&block)
      return false if not @use_em
      @on_read_lambda = lambda {|msg|
        self.rotate!
        @state = :idle
        block.call(msg)
      }
      @sockets.each do |socket|
        socket.on_read { |msg|
          @on_read_lambda.call(msg)
          #self.rotate!
          #@state = :idle
          #block.call(msg)
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
