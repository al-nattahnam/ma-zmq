module MaZMQ
  class Handler < EM::Connection
    def initialize(socket)
      @socket = socket
    end

    def notify_readable
      puts @socket.recv_string
    end

    def notify_writable
      puts 'writable'
    end
  end
end
