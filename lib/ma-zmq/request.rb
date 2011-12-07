module MaZMQ
  class Request < MaZMQ::Socket
    # mergear con RoundRobin
    socket_type ZMQ::REQ
  end
end
