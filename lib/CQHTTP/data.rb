module CQHTTP
  class DataMemory
    private

    attr_accessor :events

    def initialize
      @events = []
    end

    public

    # add event
    #
    # @param event [Hash] event that need to add
    def add_event(message)
      @events.push(message)
      nil
    end

    # get events in a time range
    #
    # @param since [Integer] begin range
    # @param to [Integer] end range
    #
    # @return [Hash]
    def get_event(since = 0, to = -1)
      next_start = @events.size
      return { next_start: next_start, events: [] } if to >= next_start
      next_start = to + 1 if to != -1
      {
        next_start: next_start,
        events: @events[since..to]
      }
    end
  end
end
