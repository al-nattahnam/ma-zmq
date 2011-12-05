module RZMQMCompat
  def recv_with_raise(msg, flags = 0)
    recv_without_raise(msg, flags)
  end
end

ZMQ::Socket.send(:include, RZMQCompat)
