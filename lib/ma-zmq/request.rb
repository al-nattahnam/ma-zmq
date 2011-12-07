module MaZMQ
  class Request < MaZMQ::SocketHandler
    # mergear con RoundRobin
    #socket_type ZMQ::REQ

    def initialize
      @socket_type = ZMQ::REQ
      super
    end
  end
end
