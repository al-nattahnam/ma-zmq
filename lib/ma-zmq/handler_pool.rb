module MaZMQ
  class HandlerPool
    def initialize(ports)
      @sockets = []
      ports.each do |port|
        socket = MaZMQ::Request.new(false) # TODO debugging only
        socket.connect :tcp, '127.0.0.1', port # TODO
        socket.timeout 5 # TODO
        @sockets << socket
      end
  
      @current = available

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries
  
      # @state = :idle
    end
  
    def send_string(msg)
      #return false unless @state == :idle
      @current.send_string(msg)
    end
  
    def recv_string
      #@current.on_timeout {
      #  return :timeout
      #}
      #@current.on_read { |msg|
      #  return msg
      #}
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
      @state = :idle
    end
  end
end
