# CQHTTP ([English](README.en.md))

[![gem version](https://img.shields.io/gem/v/CQHTTP)](https://rubygems.org/gems/CQHTTP)
[![yard docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/gems/CQHTTP)
[![pipeline status](https://gitlab.com/71e6fd52/cqhttp-ruby/badges/master/pipeline.svg)](https://gitlab.com/71e6fd52/cqhttp-ruby/pipelines)
[![inline docs](http://inch-ci.org/github/71e6fd52/cqhttp-ruby.svg?branch=master)](http://inch-ci.org/github/71e6fd52/cqhttp-ruby)

在 ruby 中使用 [richardchien/coolq-http-api](https://github.com/richardchien/coolq-http-api)。

## 安装

在你的应用的 `Gemfile` 加入这行：

```ruby
gem 'CQHTTP'
```

然后运行：

    $ bundle

或者你自己安装

    $ gem install CQHTTP

## 使用

```ruby
require 'CQHTTP'

api = CQHTTP::API.new(host: 'http://localhost:5700')
group = api.get_group_list
group.map { _1['group_id'] }.each do
  api.send_group_msg(group_id: _1, message: '大家早上好')
end
```

## 开发

检出这个仓库后，运行 `bin/setup` 来安装依赖关系。然后，运行 `rake spec` 来运行测试。 您还可以运行 `bin/console` 启动交互式提示符(`irb`)，让您进行实验。

要将此 gem 安装到本机上，请运行 `bundle exec rake install`。 要释出新版本，请在 `version.rb` 中更新版本号，然后运行 `bundle exec rake release`，该版本将为该版本创建一个 git 标签，并推送 git 提交和标签，然后将 `.gem` 文件提交到 [rubygems.org](https://rubygems.org)。

## 贡献

欢迎来 [GitHub](https://github.com/71e6fd52/cqhttp-ruby) 上发起 issues 和 pull requests
