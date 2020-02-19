# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CQHTTP::Network do
  before :all do
    @res = Struct.new(:code, :body)
  end

  it 'returns three Proc object' do
    get = CQHTTP::Network.gen :get, ''
    json = CQHTTP::Network.gen :json, ''
    form = CQHTTP::Network.gen :form, ''
    expect(get).to be_an_instance_of Proc
    expect(json).to be_an_instance_of Proc
    expect(form).to be_an_instance_of Proc
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
      expect(@method.call('/a', send)).to eq({})
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
          expect { @method.call('/a', a: 1) }.to raise_error error
        end
      end
    end
  end

  describe '#get' do
    include_examples 'clean'
    include_examples 'error', :get_response

    before :all do
      @method = CQHTTP::Network.gen :get, 'http://localhost'
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
    end
  end

  describe '#post_form' do
    include_examples 'clean'
    include_examples 'error'

    before :all do
      @method = CQHTTP::Network.gen :form, 'http://localhost'
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

  describe '#post_lson' do
    include_examples 'clean'
    include_examples 'error'

    before :all do
      @method = CQHTTP::Network.gen :json, 'http://localhost'
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
    end
  end
end
