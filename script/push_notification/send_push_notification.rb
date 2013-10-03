#!/usr/bin/env ruby
# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

STDOUT.sync = true

puts
puts "This script sends push notifications."

APNS.host = 'gateway.push.apple.com'
APNS.pem  = './script/push_notification/apns-prod.pem'

APNS.port = 2195

device_token = 'b2cb5b615220a526c776b873a511b27d25317d982c32ff6bb07fa4da82b2299b'
text = 'Runde 4 soeben gestartet: Sei jetzt von Anfang an dabei!'

APNS.send_notification(device_token, text)

puts "Done."