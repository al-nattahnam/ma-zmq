module MaZMQ
  class HandlerPool
    def initialize(ports, use_em=true)
      @sockets = []
      ports.each do |port|
        socket = MaZMQ::Request.new(use_em) # TODO debugging only
        socket.connect :tcp, '127.0.0.1', port # TODO
        @sockets << socket
      end
  
      @use_em = use_em
      @current = available

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries
  
      # @state = :idle
    end

    def timeout(secs)
      @sockets.each do |s|
        s.timeout secs
      end
    end
  
    def send_string(msg)
      #return false unless @state == :idle
      @current.send_string(msg)
    end
  
    def recv_string
      case state
        when :idle
          return false
        when :sending
          return @current.recv_string
        when :timeout
          return false
      end
    end
  
    def state
      @current.state
    end

    def on_read(&block)
      return false if not @use_em
      @sockets.each do |socket|
        socket.on_read{ |msg| block.call(msg)}
      end
    end

    def on_timeout(&block)
      return false if not @use_em
      @sockets.each do |socket|
        socket.on_timeout {
          block.call
        }
      end
    end
  
    def available
      @sockets.select{|s| s.state == :idle}.first
    end
  
    #def register_timeout
      #@current.timeouts += 1
    #end
  
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
