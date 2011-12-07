module MaZMQ
  class Request < MaZMQ::SocketHandler
    # mergear con RoundRobin
    socket_type ZMQ::REQ
  end
end
