module CQHTTP
  class <<self
    attr_accessor :logger
  end

  self.logger = Logger.new($stderr)
  logger.level = Logger::INFO
end
