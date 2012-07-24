# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# clients

payment_provider = Client.create({
  :identifier   => "Payment",
  :scopes       => "5dentity payment",
  :password     => "wacky",
  :grant_types  => "password"
}, :as => :creator)


wackadoo_client = Client.create({
  :identifier   => "WACKADOOHTML5",
  :scopes       => "5dentity wackadoo payment",
  :password     => "wacky",
  :grant_types  => "password"
}, :as => :creator)

wackadoo_game = Resource::Game.create({
  :identifier   => "WACKADOO",
  :name         => "Wack-a-Doo",
  :link         => "https://wack-a-doo.de",
  :scopes       => "5dentity",
}, :as => :creator)


# heldenduell = Client.create({
  # :identifier   => "HeldenDuell",
  # :scopes       => "5dentity heldenduell",
  # :grant_types  => "password"
# }, :as => :creator)


# test_client = Client.create({
  # :identifier   => "XYZ",
  # :scopes       => "5dentity wackadoo",
  # :grant_types  => "password"
# }, :as => :creator)


# admin identities

admin = Identity.new({
  :nickname              => "admin",
  :email                 => "admin@5dlab.com",
  :password              => "5dlab5dlab",
  :password_confirmation => "5dlab5dlab"
}, :as => :creator)

admin.admin = true
admin.staff = true
admin.save