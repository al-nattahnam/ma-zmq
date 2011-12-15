module MaZMQ
  class LoadBalancer
    # Aprovechar el tiempo de timeout para seguir mandando a los restantes
    # roundrobin
    # leastconnections
    # directed
    # priorities

    # Split LoadBalancer / Backend

    @@id = 0

    def initialize(use_em=true)
      @use_em = use_em

      @sockets = []

      @timeout = nil # TODO individual timeouts for different sockets

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      @index = []

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

      request.identity = "lb-#{@@id}"
      @@id += 1
      @sockets << request
    end

    def timeout(secs)
      @timeout = secs
      @sockets.each do |s|
        s.timeout @timeout
      end
    end

    def send_string(msg)
      @current = next_available
      return false if @current.is_a? NilClass
      case @current.state
        when :idle
          @current.send_string(msg)
          self.rotate!
        else
          return false
      end
    end

    #def recv_string
    #  msg = case @current.state
    #    when :idle then false
    #    when :sending then @current.recv_string
    #    when :timeout then false
    #  end

      # chequear @use_em = false
      #if @timeout and @current.state == :timeout
      #  rotate!
      #  @state = :retry
      #  @current.send_string @current_message
      #  return false
      #end
    #  return msg
    #end

    def on_timeout(&block)  
      return false if not @use_em
      @on_timeout_lambda = lambda {
        #@state = :retry
        #self.send_string @current_message
        block.call
      }
      @sockets.each do |socket|
        socket.on_timeout {
          @on_timeout_lambda.call
        }
      end
    end

    def on_read(&block)
      return false if not @use_em
      @on_read_lambda = lambda {|msg|
        #self.rotate!
        #@state = :idle
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

    def next_available
      @sockets.select{|s| s.state == :idle}.first || nil
    end

    def rotate!(timeout=false)
      # TODO rotar un index, de este modo seria mas rapido que el push(shift)
      #@sockets.delete_at(0)
      @sockets.push(@sockets.shift)
      #if timeout
      #  @sockets.delete_at(-1)
      #end
  
      #@current = next_available
    end
  end
end
