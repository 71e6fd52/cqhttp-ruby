# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

require 'spec_helper'
RSpec.describe CQHTTP::Network do
  before :all do
    @res = Struct.new(:code, :body)
  end

  it 'init' do
    get = CQHTTP::Network.new :get, ''
    json = CQHTTP::Network.new :json, ''
    form = CQHTTP::Network.new :form, ''
    expect(get).to be_an_instance_of CQHTTP::Network
    expect(json).to be_an_instance_of CQHTTP::Network
    expect(form).to be_an_instance_of CQHTTP::Network
  end

  shared_examples 'clean' do
    before :each do
      Net.unset
    end
  end

  shared_examples 'work' do |name, send, get|
    it name do
      http = spy('Net::HTTP', @request_name => @res.new(200, '{}'))
      Net::HTTP = http
      expect(@method.send_req('a', send)).to eq({})
      expect(http).to have_received(@request_name).with(*get)
    end

    it name + ' without result' do
      http = spy('Net::HTTP', @request_name => @res.new(200, '{}'))
      Net::HTTP = http
      expect(@method.send_req('a', send, result: false)).to be_nil
      expect(http).to have_received(@request_name).with(*get)
    end
  end

  shared_examples 'error' do
    describe 'can raise' do
      {
        400 => 'POST 请求的 Content-Type 不正确',
        401 => 'token 不符合',
        404 => 'API 不存在',
        405 => '请求方式不支持',
        418 => '418',
      }.each_pair do |code, error|
        it code do
          http = spy('Net::HTTP', @request_name => @res.new(code, '{}'))
          Net::HTTP = http
          expect { @method.send_req('a', { a: 1 }) }.to raise_error error
        end
      end
    end
  end

  describe '#get' do
    include_examples 'clean'
    include_examples 'error', :get_response

    before :all do
      @method = CQHTTP::Network.new :get, 'http://localhost'
      @request_name = :get_response
    end

    describe 'can work with' do
      include_examples 'work',
                       'without params',
                       nil,
                       [URI('http://localhost/a')]

      include_examples 'work',
                       'number',
                       { a: 1 },
                       [URI('http://localhost/a?a=1')]

      include_examples 'work',
                       'number and float',
                       { i: 1, f: 4.8 },
                       [URI('http://localhost/a?i=1&f=4.8')]

      include_examples 'work',
                       'number and two string',
                       { i: 1, str1: 'test', other: 'another' },
                       [URI('http://localhost/a?i=1&str1=test&other=another')]

      include_examples 'work',
                       'encode string',
                       { str: '😂' },
                       [URI('http://localhost/a?str=%F0%9F%98%82')]

      it 'auth' do
        a = CQHTTP::Network.new :get, 'http://localhost', 'abc'
        http = spy('Net::HTTP', @request_name => @res.new(200, '{}'))
        Net::HTTP = http
        expect(a.send_req('a', { a: 1 })).to eq({})
        expect(http).to have_received(@request_name).with(URI('http://localhost/a?a=1&access_token=abc'))
      end
    end
  end

  describe '#post_form' do
    include_examples 'clean'
    include_examples 'error'

    before :all do
      @method = CQHTTP::Network.new :form, 'http://localhost'
      @request_name = :post_form
    end

    describe 'can work with' do
      include_examples 'work',
                       'number',
                       { a: 1 },
                       [URI('http://localhost/a'), { a: 1 }]

      include_examples 'work',
                       'number and float',
                       { i: 1, f: 4.8 },
                       [URI('http://localhost/a'), { i: 1, f: 4.8 }]

      include_examples 'work',
                       'number and two string',
                       { i: 1, str1: 'test', other: 'another' },
                       [
                         URI('http://localhost/a'),
                         { i: 1, str1: 'test', other: 'another' },
                       ]
    end
  end

  describe '#post_json' do
    include_examples 'clean'
    include_examples 'error'

    before :all do
      @method = CQHTTP::Network.new :json, 'http://localhost'
      @request_name = :post
    end

    describe 'can work with' do
      include_examples 'work',
                       'number',
                       { a: 1 },
                       [
                         URI('http://localhost/a'),
                         { a: 1 }.to_json,
                         { 'Content-Type' => 'application/json' },
                       ]

      include_examples 'work',
                       'number and float',
                       { i: 1, f: 4.8 },
                       [
                         URI('http://localhost/a'),
                         { i: 1, f: 4.8 }.to_json,
                         { 'Content-Type' => 'application/json' },
                       ]

      include_examples 'work',
                       'number and two string',
                       { i: 1, str1: 'test', other: 'another' },
                       [
                         URI('http://localhost/a'),
                         { i: 1, str1: 'test', other: 'another' }.to_json,
                         { 'Content-Type' => 'application/json' },
                       ]
      it 'auth' do
        a = CQHTTP::Network.new :json, 'http://localhost', 'abc'
        http = spy('Net::HTTP', @request_name => @res.new(200, '{}'))
        Net::HTTP = http
        expect(a.send_req('a', { a: 1 })).to eq({})
        expect(http).to have_received(@request_name).with(
          URI('http://localhost/a'),
          { a: 1 }.to_json,
          { 'Content-Type' => 'application/json',
            'Authorization' => 'Bearer abc' },
        )
      end
    end
  end
end
