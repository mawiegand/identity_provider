#!/usr/bin/env ruby
#
# Script for placing npc armies and artifacts
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "Start sending bulk emails"

count = 0

#Identity.where(["(banned IS NULL OR banned = ?) AND email NOT LIKE '%deleted%' AND email NOT LIKE '%5dlab.com' AND email NOT LIKE '%pfox.eu' AND email NOT LIKE 'hajo%web.de'", false]).all do |identity|
Identity.where("email LIKE '%pfox.eu'").all do |identity|
  
  IdentityMailer.all_players_notice_email(identity, "Soeben ist Runde 3 von Wack-A-Doo gestartet!").deliver
  count = count + 1
  
  if count % 10 == 0
    sleep 5
  end
  
  if count % 5 == 0
    puts "."
  end
  
end


puts "NPC PLACEMENT: Finished all tasks."
