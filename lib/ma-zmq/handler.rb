module MaZMQ
  class Handler < EM::Connection
    def initialize(socket)
      @socket = socket
    end

    def notify_readable
      puts 'readable'
      msg = @socket.recv_string
      return unless msg
      puts msg
    end

    def notify_writable
      puts 'writable'
    end
  end
end
