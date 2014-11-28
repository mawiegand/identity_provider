#!/usr/bin/env ruby
#
# Script for placing npc armies and artifacts
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

puts "Start sending bulk emails"

count = 0

file = File.new(File.join(Rails.root, "sent_emails.txt"), 'w' );

#Identity.where("locale = 'de' AND (banned IS NULL OR banned = ?) AND email NOT LIKE '%deleted%' AND email NOT LIKE '%5dlab.com' AND email NOT LIKE '%pfox.eu'", false).all do |identity|
#Identity.where("email LIKE '%pfox.eu'").each do |identity|
Identity.where("email LIKE 'sascha@5dlab.com'").each do |identity|
  
  IdentityMailer.all_players_notice_email(identity, "Wack-A-Doo 2.0: Runde 7 gestartet!").deliver
  count = count + 1
  
  file.write("#{identity.email},\n")
  puts "#{identity.email}"
  
  if count % 5 == 0
    sleep 1
  end
  
  if count % 25 == 0
    puts "\n--------------- #{count}\n\n"
  end
  
end

file.close

puts "Sent all emails."
