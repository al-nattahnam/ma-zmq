module RZMQMCompat
  def self.included(klass)
    klass.instance_eval do
      %w(recv).each do |m|
        alias_method :"#{m}_without_raise", m.to_sym
        alias_method m.to_sym, :"#{m}_with_raise"
      end
    end
  end

  def recv_with_raise(msg, flags = 0)
    recv_without_raise(msg, flags)
  end
end

ZMQ::Socket.send(:include, RZMQCompat)
