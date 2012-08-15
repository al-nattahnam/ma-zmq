require 'spec_helper'

describe MaZMQ::SocketHandler do
  context "::valid_address" do
    it "should return false with invalid protocol" do
      MaZMQ::SocketHandler.valid_address("invalid_protocol", "127.0.0.1", 5235).should == false
    end

    context "tcp protocol" do
      it "should return a String with valid address" do
        MaZMQ::SocketHandler.valid_address(:tcp, "127.0.0.1", 5235).should == "tcp://127.0.0.1:5235"
        MaZMQ::SocketHandler.valid_address("tcp", "127.0.0.1", 5235).should == "tcp://127.0.0.1:5235"
      end

      it "should return false with invalid address" do
        MaZMQ::SocketHandler.valid_address(:tcp, "127.0.0.1", "invalid_port").should == false
      end
    end

    context "ipc protocol" do
      it "should return a String with valid address" do
        MaZMQ::SocketHandler.valid_address(:ipc, "/tmp/socket.sock").should == "ipc:///tmp/socket.sock"
        MaZMQ::SocketHandler.valid_address("ipc", "/tmp/socket.sock").should == "ipc:///tmp/socket.sock"
      end

      it "should return false with invalid address" do
        MaZMQ::SocketHandler.valid_address(:ipc, "/tmp/socket.sock", 5234).should == false
      end
    end

    context "inproc protocol" do
      it "should return a String with valid address" do
        MaZMQ::SocketHandler.valid_address(:inproc, "test_channel").should == "inproc://test_channel"
        MaZMQ::SocketHandler.valid_address("inproc", "test_channel").should == "inproc://test_channel"
      end

      it "should return false with invalid address" do
        MaZMQ::SocketHandler.valid_address(:inproc, "test_channel", 5234).should == false
      end
    end
  end

end
