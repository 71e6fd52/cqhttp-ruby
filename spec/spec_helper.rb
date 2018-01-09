require 'bundler/setup'
require 'CQHTTP'

require 'coco'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Net
  def self.unset
    remove_const(:HTTP) if const_defined? :HTTP
  end
end
