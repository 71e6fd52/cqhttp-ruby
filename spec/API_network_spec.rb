# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

require 'spec_helper'
RSpec.describe CQHTTP::API do
  before :all do
    @res = Struct.new(:code, :body)
  end

  before :each do
    Net.unset
  end

  shared_examples 'work' do |name, send, get|
    it name do
      http = spy('Net::HTTP', @request_name => @res.new(200, '{}'))
      Net::HTTP = http
      expect(send.call(@api)).to eq({})
      expect(http).to have_received(@request_name).with(*get)
    end
  end

  describe 'can work with' do
    describe 'get' do
      before :all do
        @api = CQHTTP::API.new way: :get
        @request_name = :get_response
      end

      include_examples(
        'work',
        'get_login_info',
        proc { _1.get_login_info },
        [URI('http://localhost:5700/get_login_info?')],
      )

      include_examples(
        'work',
        'send_group_msg',
        proc { _1.send_group_msg('123456', 'test') },
        [URI('http://localhost:5700/send_group_msg?group_id=123456&message=test&auto_escape=false')],
      )
    end

    describe 'form' do
      before :all do
        @api = CQHTTP::API.new way: :form
        @request_name = :post_form
      end

      include_examples(
        'work',
        'get_login_info',
        proc { _1.get_login_info },
        [URI('http://localhost:5700/get_login_info'), {}],
      )

      include_examples(
        'work',
        'send_group_msg',
        proc { _1.send_group_msg('123456', 'test') },
        [URI('http://localhost:5700/send_group_msg'),
         { group_id: '123456', message: 'test', auto_escape: false }],
      )

      it 'send_group_msg whth keyword params' do
        http = spy('Net::HTTP', post_form: @res.new(200, '{}'))
        Net::HTTP = http
        expect(@api.send_group_msg(group_id: '123456', message: 'test'))
          .to eq({})
        expect(http).to have_received(:post_form).with(
          URI('http://localhost:5700/send_group_msg'),
          group_id: '123456', message: 'test', auto_escape: false,
        )
      end
    end

    describe 'callback' do
      before :each do
        @return = 'custom return'
        @double = double('Proc', call: @return)
        @api = CQHTTP::API.new(way: :callback, callback: @double)
      end

      it 'raise withou callback' do
        expect { @api = CQHTTP::API.new(way: :callback) }.to \
          raise_error 'Not pass callback'
      end

      it 'get_login_info' do
        expect(@api.get_login_info).to be @return
        expect(@double).to have_received(:call).with('get_login_info', {})
      end

      it 'send_group_msg' do
        expect(@api.send_group_msg('123456', 'test')).to be @return
        expect(@double).to have_received(:call).with(
          'send_group_msg',
          group_id: '123456', message: 'test', auto_escape: false,
        )
      end
    end
  end
end
