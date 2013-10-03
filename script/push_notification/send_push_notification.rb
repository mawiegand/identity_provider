#!/usr/bin/env ruby
# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

STDOUT.sync = true

puts
puts "This script sends push notifications."

APNS.host = 'gateway.push.apple.com'
APNS.pem  = './script/push_notification/apns-prod.pem'

APNS.port = 2195

text = 'Runde 4 soeben gestartet: Sei jetzt von Anfang an dabei!'

Identity.all.each do |identity|
  push_token = identity.push_tokens.order('updated_at').last
  unless push_token.nil?
    parsed_token = push_token.push_notification_token.sub(/</, '').sub(/>/, '').sub(/ /, '').sub(/ /, '').sub(/ /, '').sub(/ /, '').sub(/ /, '').sub(/ /, '').sub(/ /, '')
    puts "send token to #{identity.nickname} #{identity.email} #{parsed_token}"
    #APNS.send_notification(parsed_token, text)
    sleep 1
  end
end

puts "Done."