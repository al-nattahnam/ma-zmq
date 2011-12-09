require 'eventmachine'
require 'ffi-rzmq'

require 'ma-zmq/round_robin'
require 'ma-zmq/handler_pool'

#require 'ma-zmq/socket_pool'
#require 'ma-zmq/channel'

require 'ma-zmq/connection_handler'
require 'ma-zmq/socket_handler'

require 'ma-zmq/request'
require 'ma-zmq/reply'

module MaZMQ
  @@context = nil
  def self.context
    # Como MaZMQ estaria funcionando siempre en EM, el proceso en el cual corre seria siempre unico, y por esa razon (repasando http://zguide.zeromq.org/page:all#Getting-the-Context-Right), usamos un unico Contexto en toda la aplicacion. Y el usuario no tiene que instanciar uno.
    @@context ||= ZMQ::Context.new
    @@context
  end
end
