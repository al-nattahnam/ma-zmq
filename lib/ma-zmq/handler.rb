module MaZMQ
  class Handler < EM::Connection
    def initialize(socket)
      @socket = socket
    end

    def notify_readable
      puts 'readable'
    end

    def notify_writable
      puts 'writable'
    end
  end
end
