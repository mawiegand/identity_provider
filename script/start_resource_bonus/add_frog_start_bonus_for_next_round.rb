#!/usr/bin/env ruby
#
# Helper script for adding frog start bonus for new round to all players who signed in during last round
#

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'config', 'environment'))

STDOUT.sync = true


##
# global constants
##
number_of_last_round = 7 # number of last round
frog_bonus_amount = 80 # frog bonus amount for next round

# get start date of last round
game_instance = Game::GameInstance.find_by_number(number_of_last_round)
last_round_start_date = game_instance.started_at # round start date for comparison with last login date

puts "Adding #{frog_bonus_amount} frogs to all identities which signed in during round #{number_of_last_round} (after #{last_round_start_date})."

identities = Identity.joins("LEFT OUTER JOIN log_entries ON log_entries.identity_id = identities.id")
             .where("log_entries.identity_id IS NOT NULL AND (event_type ='signin_success' OR event_type = 'auth_token_success')")
             .where(["log_entries.created_at > ?", last_round_start_date-1.days])
             .select("DISTINCT(identity.id)")

# PRODUCES THE FOLLOWING SQL:
# SELECT DISTINCT(identity.id) FROM "identities" LEFT OUTER JOIN log_entries ON log_entries.identity_id = identities.id WHERE (log_entries.identity_id IS NOT NULL AND (event_type ='signin_success' OR event_type = 'auth_token_success')) AND (log_entries.created_at > '2014-12-18 17:59:08')


# for each identity
identities.each do |identity|
  puts "Identity: #{identity.id}"
    
    # add frog bonus amount
   #  Resource::CharacterProperty.create(game_id: 1,
   #                                     identity_id: identity.id,
  #                                     data: {client_identifier: "wackadoo", start_resource_bonus: [{resource_type_id: 3, amount: frog_bonus_amount}]}
  #  )
  end
end

puts "Finished."
