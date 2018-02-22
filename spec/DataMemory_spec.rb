require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CQHTTP::DataMemory do
  before :each do
    @database = CQHTTP::DataMemory.new
  end

  it 'can add two message and get' do
    @database.add_event(time: 123)
    @database.add_event(time: 456)
    expect(@database.get_event[:events]).to eq(
      [
        { time: 123 },
        { time: 456 }
      ]
    )
  end

  it 'can add and get message each two' do
    @database.add_event(time: 123)
    @database.add_event(time: 456)
    event = @database.get_event
    expect(event[:events]).to eq(
      [
        { time: 123 },
        { time: 456 }
      ]
    )
    @database.add_event(time: 457)
    @database.add_event(time: 458)
    event = @database.get_event(event[:next_start])
    expect(event[:events]).to eq(
      [
        { time: 457 },
        { time: 458 }
      ]
    )
    event = @database.get_event(event[:next_start])
    expect(event[:events]).to eq([])
    event = @database.get_event(event[:next_start])
    expect(event[:events]).to eq([])
  end

  it 'work when empty' do
    expect(@database.get_event[:events]).to eq([])
  end

  it 'can add four message and get each two' do
    @database.add_event(time: 457)
    @database.add_event(time: 123)
    @database.add_event(time: 458)
    @database.add_event(time: 456)
    event = @database.get_event(0, 1)
    expect(event[:events]).to eq(
      [
        { time: 123 },
        { time: 456 }
      ]
    )
    event = @database.get_event(event[:next_start])
    expect(event[:events]).to eq(
      [
        { time: 457 },
        { time: 458 }
      ]
    )
  end
end
# rubocop:enable Metrics/BlockLength
