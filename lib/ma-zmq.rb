require 'eventmachine'
require 'ffi-rzmq'

require 'ma-zmq/connection_handler'
require 'ma-zmq/socket_handler'

require 'ma-zmq/request'
require 'ma-zmq/reply'

require 'ma-zmq/push'
require 'ma-zmq/pull'

require 'ma-zmq/proxy/backend'
require 'ma-zmq/proxy/balancer'
require 'ma-zmq/proxy'

module MaZMQ
  @@context = nil
  def self.context
    # Como MaZMQ estaria funcionando siempre en EM, el proceso en el cual corre seria siempre unico, y por esa razon (repasando http://zguide.zeromq.org/page:all#Getting-the-Context-Right), usamos un unico Contexto en toda la aplicacion. Y el usuario no tiene que instanciar uno.
    @@context ||= ZMQ::Context.new
    @@context
  end

  def self.terminate
    @@context.terminate if @@context
  end
end
