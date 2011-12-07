module MaZMQ
  class Socket
    @@protocols = [:tcp, :inproc, :ipc] #, :pgm]

    def self.socket_type(socket_type)
      @@socket_type = socket_type
    end

    protected
    def self.valid_protocol?(protocol)
      @@protocols.include? protocol
    end
  end
end
