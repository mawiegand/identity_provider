#!/usr/bin/env ruby
#
# Script for placing npc armies and artifacts
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'credit_shop'

puts "Start updating stats"

puts "Updating Stats of all Identities"

Identity.update_stats_of_all_identities

puts "Updating Money Transactions"

CreditShop::BytroShop.update_money_transactions

puts "Updating Churn"

Identity.all.each do |identity|
  latest_sign_in = identity.auth_successes.latest.first
  
  if latest_sign_in.nil?
    identity.age_in_hours = 0
    identity.age_days = 0
  else 
    identity.age_in_hours = (latest_sign_in.created_at - identity.created_at) / 3600
    identity.age_days     = (latest_sign_in.created_at.beginning_of_day - identity.created_at.beginning_of_day) / (3600*24)
  end
    
  identity.save(:validate => false)
end
