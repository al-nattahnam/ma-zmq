module MaZMQ
  class Proxy
    # consistira en el indice y referencia a los sockets del backend
    # roundrobin
    # leastconnections
    # directed
    # priorities

    include MaZMQ::Proxy::Backend

    @@id = 0

    def initialize(use_em=true)

      @index = []

      # @max_timeouts = 5 # TODO
      # @max_timeouted = 1
      # @max_retries

      super(use_em)
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

    def next_available
      @sockets.select{|s| s.state == :idle}.first || nil
    end

    def rotate!(timeout=false)
      # TODO rotar un index, de este modo seria mas rapido que el push(shift)
      #@sockets.delete_at(0)
      @sockets.push(@sockets.shift)
    end
  end
end
