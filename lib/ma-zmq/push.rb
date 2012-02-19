module MaZMQ
  class Push < MaZMQ::SocketHandler
    attr_reader :state

    def initialize(use_eventmachine=true)
      @socket_type = ZMQ::PUSH
      super(use_eventmachine)
    end
  end
end
