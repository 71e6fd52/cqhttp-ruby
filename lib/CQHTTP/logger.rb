module CQHTTP
  class <<self
    attr_accessor :logger

    self.logger = ::Logger.new($stderr)
    logger.level = level
  end
end
