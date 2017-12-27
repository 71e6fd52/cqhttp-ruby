require 'spec_helper'

RSpec.describe CQHTTP::DataMemory do
  before :each do
    @database = CQHTTP::DataMemory.new
  end

  it 'can add message and get it' do
    @database.add_event(JSON.parse('{"time": "0"}'))
    expect(@database.get_event(0, -1)).to eq(
      next_start: 1,
      events: [
        'time' => '0'
      ]
    )
  end
end
