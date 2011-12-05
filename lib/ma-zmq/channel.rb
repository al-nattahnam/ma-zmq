require 'timeout'

module MaZMQ
  class Channel
    attr_accessor :state
  
    def initialize(context, port, timeout = 1)
      #@socket = context.socket ZMQ::REQ
      #@socket.connect("tcp://127.0.0.1:#{port}")
      @socket = context.connect(ZMQ::REQ, "tcp://127.0.0.1:#{port}").socket
  
      @timeout = timeout
      @state = :idle
    end
  
    def send_string(msg)
      return false unless @state == :idle
      
      @socket.send_string(msg)
  
      @state = :sending
      return @state
    end
  
    def recv_string
      return :timeout if @state == :timeout
      return false unless @state == :sending
  
      resp = ''
      begin
        Timeout::timeout(@timeout) do
          @socket.recv_string(resp)
        end
      rescue Timeout::Error
        @state = :timeout
        return @state
      end
  
      @state = :idle
      return resp
    end
  
    def idle
      @state = :idle
    end
  end
end
