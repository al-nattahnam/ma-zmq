module MaZMQ
  class Reply < MaZMQ::SocketHandler
    # mergear con RoundRobin
    #socket_type ZMQ::REP

    def initialize(use_eventmachine=true)
      @socket_type = ZMQ::REP
      super(use_eventmachine)
    end
  end
end
