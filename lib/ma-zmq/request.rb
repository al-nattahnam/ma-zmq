module MaZMQ
  class Request < MaZMQ::SocketHandler
    # mergear con RoundRobin
    #socket_type ZMQ::REQ

    def initialize(use_eventmachine=true)
      @socket_type = ZMQ::REQ
      super(use_eventmachine)
    end
  end
end
