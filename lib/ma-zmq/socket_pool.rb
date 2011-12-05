require 'channel'

module MaZMQ
  class SocketPool
    def initialize(context, ports)
      @context = context # ZMQ::Context.new
      @sockets = []
      ports.each do |port|
        @sockets << MaZMQ::Channel.new(@context, port, 1)
      end
  
      @current = available
  
      @state = :idle
    end
  
    def send_string(msg)
      return false unless @state == :idle
      @state = @current.send_string(msg)
    end
  
    def recv_string
      return false unless @state == :sending
      msg = @current.recv_string
      puts "pool: recv #{msg}"
      @state = @current.state
      if @state == :idle
        return msg
      elsif @state == :timeout
        @current.idle
      end
      return @current.state
    end
  
    def state
      @state
    end
  
    def message
      @msg
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
