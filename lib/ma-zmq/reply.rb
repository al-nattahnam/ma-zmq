module MaZMQ
  class Reply < MaZMQ::SocketHandler
    # mergear con RoundRobin
    #socket_type ZMQ::REP

    def initialize
      @socket_type = ZMQ::REP
      super
    end
  end
end
