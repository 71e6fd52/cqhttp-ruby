# frozen_string_literal: true

require 'spec_helper'

List = JSON.parse '{
  "send_private_msg": {
    "user_id": null,
    "message": null,
    "auto_escape": false
  },
  "send_group_msg": {
    "group_id": null,
    "message": null,
    "auto_escape": false
  },
  "send_discuss_msg": {
    "discuss_id": null,
    "message": null,
    "auto_escape": false
  },
  "send_msg": {
    "message_type": null,
    "user_id": null,
    "group_id": null,
    "discuss_id": null,
    "message": null,
    "auto_escape": false
  },
  "delete_msg": {
    "message_id": null
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
    "anonymous": null,
    "anonymous_flag": null,
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
    "sub_type": null,
    "approve": true,
    "reason": ""
  },
  "get_login_info": {
  },
  "get_stranger_info": {
    "user_id": null,
    "no_cache": false
  },
  "get_group_list": {
  },
  "get_group_member_info": {
    "group_id": null,
    "user_id": null,
    "no_cache": false
  },
  "get_group_member_list": {
    "group_id": null
  },
  "get_cookies": {
  },
  "get_csrf_token": {
  },
  "get_credentials": {
  },
  "get_record": {
    "file": null,
    "out_format": null,
    "full_path": false
  },
  "get_image": {
    "file": null
  },
  "can_send_image": {
  },
  "can_send_record": {
  },
  "get_status": {
  },
  "get_version_info": {
  },
  "set_restart_plugin": {
    "delay": 0
  },
  "clean_data_dir": {
    "data_dir": null
  },
  "clean_plugin_log": {
  }
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
end
