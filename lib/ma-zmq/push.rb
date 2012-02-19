module MaZMQ
  class Push < MaZMQ::SocketHandler
    attr_reader :state

    def initialize
      @socket_type = ZMQ::PUSH
      super
    end
  end
end
