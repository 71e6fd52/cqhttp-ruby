# CQHTTP ([中文](README.md))

[![gem version](https://img.shields.io/gem/v/CQHTTP)](https://rubygems.org/gems/CQHTTP)
[![yard docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://rubydoc.info/gems/CQHTTP)
[![pipeline status](https://gitlab.com/71e6fd52/cqhttp-ruby/badges/master/pipeline.svg)](https://gitlab.com/71e6fd52/cqhttp-ruby/pipelines)
[![inline docs](http://inch-ci.org/github/71e6fd52/cqhttp-ruby.svg?branch=master)](http://inch-ci.org/github/71e6fd52/cqhttp-ruby)

This gem can make you use [richardchien/coolq-http-api](https://github.com/richardchien/coolq-http-api) in ruby.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'CQHTTP'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install CQHTTP

## Usage

```ruby
require 'CQHTTP'

api = CQHTTP::API.new(host: 'http://localhost:5700')
group = api.get_group_list
group.map { _1['group_id'] }.each do
  api.send_group_msg(group_id: _1, message: 'Good morning everyone')
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/71e6fd52/cqhttp-ruby
