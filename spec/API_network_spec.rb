require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CQHTTP::API do
  before :all do
    @res = Struct.new(:code, :body)
  end

  before :each do
    Net.unset
  end

  describe 'can work with' do
    describe 'get' do
      before :all do
        @api = CQHTTP::API.new way: :get
      end

      it 'get_login_info' do
        http = spy('Net::HTTP', get_response: @res.new(200, '{}'))
        Net::HTTP = http
        expect(@api.get_login_info).to eq({})
        expect(http).to have_received(:get_response).with(
          URI('http://localhost:5700/get_login_info?')
        )
      end

      it 'send_group_msg' do
        http = spy('Net::HTTP', get_response: @res.new(200, '{}'))
        Net::HTTP = http
        expect(@api.send_group_msg('123456', 'test')).to eq({})
        expect(http).to have_received(:get_response).with(
          URI('http://localhost:5700/send_group_msg?group_id=123456&message=test&auto_escape=false')
        )
      end
    end

    describe 'form' do
      before :all do
        @api = CQHTTP::API.new way: :form
      end

      it 'get_login_info' do
        http = spy('Net::HTTP', post_form: @res.new(200, '{}'))
        Net::HTTP = http
        expect(@api.get_login_info).to eq({})
        expect(http).to have_received(:post_form).with(
          URI('http://localhost:5700/get_login_info'), {}
        )
      end

      it 'send_group_msg' do
        http = spy('Net::HTTP', post_form: @res.new(200, '{}'))
        Net::HTTP = http
        expect(@api.send_group_msg('123456', 'test')).to eq({})
        expect(http).to have_received(:post_form).with(
          URI('http://localhost:5700/send_group_msg'),
          group_id: '123456', message: 'test', auto_escape: false
        )
      end
    end
  end
end
