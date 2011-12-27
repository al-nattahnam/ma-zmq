module MaZMQ
  class Proxy
    include MaZMQ::Proxy::Backend

    @@id = 0

    def initialize(use_em=true)

      #@index = []

      @balancer = MaZMQ::Proxy::Balancer.new

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      super(use_em)
    end

    def send_string(msg)
      @current = current_socket
      return false if @current.is_a? NilClass
      case @current.state
        when :idle
          @current.send_string(msg)
          next_socket
        else
          return false
      end
    end

    #def current_socket
    #  @sockets.select{|s| s.state == :idle}.first || nil
    #end

    #def next_available
    #  @sockets.select{|s| s.state == :idle}.first || nil
    #end

    def next_socket(index)
      # TODO rotar un index, de este modo seria mas rapido que el push(shift)
      #@sockets.delete_at(0)
      @sockets.push(@sockets.shift)
    end
  end
end
