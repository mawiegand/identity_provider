#!/usr/bin/env ruby
#
# Script for placing npc armies and artifacts
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'httparty'


base = 'https://wack-a-doo.de/identity_provider'

refs = [ "test_1", "test_2", "test_3", "test_4", "test_5", "test_6", "test_7", "test_7", "test_8", "test_9"  ]
subs = [ "01", "02", "03", "03", "03", "04", "05", "05"]

devices = InstallTracking::Device.select('DISTINCT vendor_token').limit(2)

devices.each do |device|
  unless device[:vendor_token].blank?
    token = device[:vendor_token]
    ref = refs.sample
    sub = subs.sample

    url  = base + "/trac?ref_id=" + ref + "&sub_id=" + sub + "&device_id=" + token
    HTTParty.get(url)
  end
end