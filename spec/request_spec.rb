require 'spec_helper'

describe MaZMQ::Request do
  before(:each) do
    @reply = MaZMQ::Reply.new
    @request = MaZMQ::Request.new
  end

  context 'when it is not connected to a Reply' do
    it "should be in 'unavailable' state" do
      @request.state.should == :unavailable
    end
  end

  context 'when requesting to a listening Reply' do
    before do
      @reply.bind :tcp, '127.0.0.1', 3000
      @request.connect :tcp, '127.0.0.1', 3000
    end

    it "should receive a response" do
      @request.send_string("request").should == :sending; sleep 1

      @reply.recv_string

      @reply.send_string "response"; sleep 1

      @request.recv_string.should == "response"
    end

    it "should change its state" do
      @request.state.should == :idle

      @request.send_string("request"); sleep 1
      @request.state.should == :sending

      @reply.recv_string

      @reply.send_string "response"; sleep 1

      @request.recv_string
      @request.state.should == :idle
    end
  end

  after(:each) do
    @reply.close
    @request.close
    sleep 1
  end
end
