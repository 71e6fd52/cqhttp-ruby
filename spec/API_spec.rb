require 'spec_helper'

List = JSON.parse '{
  "get_login_info": {},
  "send_private_msg": {
    "user_id": null,
    "message": null,
    "is_raw": false
  },
  "send_group_msg": {
    "group_id": null,
    "message": null,
    "is_raw": false
  },
  "send_discuss_msg": {
    "discuss_id": null,
    "message": null,
    "is_raw": false
  },
  "send_like": {
    "user_id": null,
    "times": 1
  },
  "set_group_kick": {
    "group_id": null,
    "user_id": null,
    "reject_add_request": false
  },
  "set_group_ban": {
    "group_id": null,
    "user_id": null,
    "duration": 1800
  },
  "set_group_anonymous_ban": {
    "group_id": null,
    "flag": null,
    "duration": 1800
  },
  "set_group_whole_ban": {
    "group_id": null,
    "enable": true
  },
  "set_group_admin": {
    "group_id": null,
    "user_id": null,
    "enable": true
  },
  "set_group_anonymous": {
    "group_id": null,
    "enable": true
  },
  "set_group_card": {
    "group_id": null,
    "user_id": null,
    "card": ""
  },
  "set_group_leave": {
    "group_id": null,
    "is_dismiss": false
  },
  "set_group_special_title": {
    "group_id": null,
    "user_id": null,
    "special_title": "",
    "duration": -1
  },
  "set_discuss_leave": {
    "discuss_id": null
  },
  "set_friend_add_request": {
    "flag": null,
    "approve": true,
    "remark": ""
  },
  "set_group_add_request": {
    "flag": null,
    "type": null,
    "approve": true,
    "reason": ""
  },
  "get_group_list": {},
  "get_group_member_info": {
    "group_id": null,
    "user_id": null,
    "no_cache": false
  },
  "get_group_member_list": {
    "group_id": null
  },
  "get_stranger_info": {
    "user_id": null,
    "no_cache": false
  },
  "get_cookies": {},
  "get_csrf_token": {},
  "get_version_info": {}
}', symbolize_names: true

RSpec.describe CQHTTP::API do
  before :all do
    @api = CQHTTP::API.new way: :get
  end

  it 'returns a CQHTTP:API object' do
    expect(@api).to be_an_instance_of CQHTTP::API
  end

  it 'including right func_list' do
    expect(@api.func_list).to eq List
  end

  List.each_key do |func|
    it 'respond to' + func.to_s do
      expect(@api.respond_to?(func)).to be true
    end
  end

  it 'can work' do
    @res = Struct.new(:code, :body)
    http = spy('Net::HTTP', get_response: @res.new(200, '{}'))
    module Net; end
    Net::HTTP = http
    expect(@api.send_group_msg('123456', 'test')).to eq({})
    expect(http).to have_received(:get_response).with(
      URI('http://localhost:5700/send_group_msg?group_id=123456&message=test&is_raw=false')
    )
  end
end
