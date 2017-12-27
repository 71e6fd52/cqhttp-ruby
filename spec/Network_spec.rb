require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CQHTTP::Network do
  before :all do
    @res = Struct.new(:code, :body)
  end

  it 'can return get as Proc object' do
    get = CQHTTP::Network.gen :get, ''
    expect(get).to be_an_instance_of Proc
  end

  it 'can return post as Proc object' do
    post = CQHTTP::Network.gen :post, ''
    expect(post).to be_an_instance_of Proc
  end

  shared_examples 'clean' do
    before :each do
      Net.unset
    end
  end

  describe '#get' do
    include_examples 'clean'

    before :all do
      @method = CQHTTP::Network.gen :get, 'http://localhost'
    end

    it 'can work' do
      http = spy('Net::HTTP', get_response: @res.new(200, '{"retcode": 0}'))
      Net::HTTP = http
      expect(@method.call('/a')).to eq('retcode' => 0)
      expect(http).to \
        have_received(:get_response).with(URI('http://localhost/a'))
    end

    context 'can raise' do
      context 'network error' do
        {
          400 => 'POST 请求的 Content-Type 不正确',
          401 => 'token 不符合',
          404 => 'API 不存在',
          405 => '请求方式不支持'
        }.each_pair do |code, error|
          it code do
            http = spy(
              'Net::HTTP',
              get_response: @res.new(code, '{"retcode": 0}')
            )
            Net::HTTP = http
            expect { @method.call('/a') }.to raise_error error
          end
        end
      end

      context 'cqhttp error' do
        it 1 do
          http = spy(
            'Net::HTTP',
            get_response: @res.new(200, '{"retcode": 1}')
          )
          Net::HTTP = http
          expect { @method.call('/a') }
        end
        it 100 do
          http = spy(
            'Net::HTTP',
            get_response: @res.new(200, '{"retcode": 100}')
          )
          Net::HTTP = http
          expect { @method.call('/a') }.to raise_error '参数错误'
        end
        it 102 do
          http = spy(
            'Net::HTTP',
            get_response: @res.new(200, '{"retcode": 102}')
          )
          Net::HTTP = http
          expect { @method.call('/a') }.to raise_error '没有权限'
        end
      end
    end
  end

  describe '#post' do
    include_examples 'clean'

    before :all do
      @method = CQHTTP::Network.gen :post, 'http://localhost'
    end

    context 'can work with' do
      it 'number and float' do
        http = spy('Net::HTTP', post: @res.new(200, '{"retcode": 0}'))
        Net::HTTP = http
        expect(@method.call('/a', i: 1, f: 4.8)).to eq('retcode' => 0)
        expect(http).to have_received(:post).with(
          URI('http://localhost/a'),
          { i: 1, f: 4.8 }.to_json,
          'Content-Type' => 'application/json'
        )
      end
      it 'number and two string' do
        http = spy('Net::HTTP', post: @res.new(200, '{"retcode": 0}'))
        Net::HTTP = http
        expect(@method.call('/b', i: 123_456, str: 'test', hello: 'world')).to \
          eq('retcode' => 0)
        expect(http).to have_received(:post).with(
          URI('http://localhost/b'),
          { i: 123_456, str: 'test', hello: 'world' }.to_json,
          'Content-Type' => 'application/json'
        )
      end
    end

    context 'can raise' do
      context 'network error' do
        {
          400 => 'POST 请求的 Content-Type 不正确',
          401 => 'token 不符合',
          404 => 'API 不存在',
          405 => '请求方式不支持'
        }.each_pair do |code, error|
          it code do
            http = spy('Net::HTTP', post: @res.new(code, '{}'))
            Net::HTTP = http
            expect { @method.call('/a', a: 1) }.to raise_error error
          end
        end
      end

      context 'cqhttp error' do
        it 1 do
          http = spy('Net::HTTP', post: @res.new(200, '{"retcode": 1}'))
          Net::HTTP = http
          expect { @method.call('/a', a: 1) }
        end
        it 100 do
          http = spy('Net::HTTP', post: @res.new(200, '{"retcode": 100}'))
          Net::HTTP = http
          expect { @method.call('/a', a: 1) }.to raise_error '参数错误'
        end
        it 102 do
          http = spy('Net::HTTP', post: @res.new(200, '{"retcode": 102}'))
          Net::HTTP = http
          expect { @method.call('/a', a: 1) }.to raise_error '没有权限'
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
