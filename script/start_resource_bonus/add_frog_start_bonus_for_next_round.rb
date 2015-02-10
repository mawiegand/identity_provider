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

# for each identity
Identity.all.each do |identity|
  latest_sign_in = identity.auth_successes.latest.first

  # if user signed in last round
  if !latest_sign_in.nil? && latest_sign_in.created_at >= last_round_start_date
    # add frog bonus amount
    Resource::CharacterProperty.create(game_id: 1,
                                       identity_id: identity.id,
                                       data: {start_resource_bonus: [{resource_type_id: 3, amount: frog_bonus_amount}]}
    )
  end
end

puts "Finished."
