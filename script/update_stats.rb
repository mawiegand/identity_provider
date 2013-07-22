#!/usr/bin/env ruby
#
# Script for placing npc armies and artifacts
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "Start updating stats"

Identity.all.each do |identity|
  latest_sign_in = identity.sign_ins.latest.first
  
  if latest_sign_in.nil?
    identity.age_in_hours = 0
    identity.age_days = 0
  else 
    identity.age_in_hours = (latest_sign_in.created_at - identity.created_at) / 3600
    identity.age_days     = (latest_sign_in.created_at.beginning_of_day - identity.created_at.beginning_of_day) / (3600*24)
  end
  identity.save
end
