module MaZMQ
  class Reply < MaZMQ::SocketHandler
    # mergear con RoundRobin
    socket_type ZMQ::REP
  end
end
