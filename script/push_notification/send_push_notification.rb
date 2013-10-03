#!/usr/bin/env ruby
# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

STDOUT.sync = true

puts
puts "This script sends push notifications."

APNS.host = 'gateway.push.apple.com'
APNS.pem  = './script/push_notification/apns-prod.pem'

APNS.port = 2195

device_token = 'c6e55543ffc00c85cf235e481b7b78e074c3a1d6c2d5a5f5b743cac9ecfbf5c1'
text = 'Runde 4 soeben gestartet: Sei jetzt von Anfang an dabei!'

APNS.send_notification(device_token, text)

puts "Done."