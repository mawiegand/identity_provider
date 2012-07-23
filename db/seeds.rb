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


# identities

# sascha 

sascha = Identity.new({
  :nickname              => "Sascha",
  :surname               => "Lange",
  :firstname             => "Sascha",
  :email                 => "sascha@5dlab.com",
  :password              => "1.A-V.vW",
  :password_confirmation => "1.A-V.vW"
}, :as => :creator)

sascha.admin = true
sascha.staff = true
sascha.save

sascha.grants.create({
  client_id: wackadoo_client.id,
  scopes:    wackadoo_client.scopes,
});


# patrick

patrick = Identity.new({
  :nickname              => "Patrick",
  :surname               => "Fox",
  :firstname             => "Patrick",
  :email                 => "patrick@5dlab.com",
  :password              => "1.A-V.vW",
  :password_confirmation => "1.A-V.vW"
}, :as => :creator)

patrick.admin = true
patrick.staff = true
patrick.save

patrick.grants.create({
  client_id: wackadoo_client.id,
  scopes:    wackadoo_client.scopes,
});


# hajo

hajo = Identity.new({
  :nickname              => "Hajo",
  :surname               => "Runne",
  :firstname             => "Hajo",
  :email                 => "hajo@5dlab.com",
  :password              => "1.A-V.vW",
  :password_confirmation => "1.A-V.vW"
}, :as => :creator)

hajo.admin = true
hajo.staff = true
hajo.save

hajo.grants.create({
  client_id: wackadoo_client.id,
  scopes:    wackadoo_client.scopes,
});


# max

max = Identity.new({
  :nickname              => "Max",
  :surname               => "Buck",
  :firstname             => "Max",
  :email                 => "max@5dlab.com",
  :password              => "1.A-V.vW",
  :password_confirmation => "1.A-V.vW"
}, :as => :creator)

max.admin = true
max.staff = true
max.save

max.grants.create({
  client_id: wackadoo_client.id,
  scopes:    wackadoo_client.scopes,
});


# julian

julian = Identity.new({
  :nickname  => "Julian",
  :surname               => "Schmid",
  :firstname             => "Julian",
  :email                 => "julian@5dlab.com",
  :password              => "1.A-V.vW",
  :password_confirmation => "1.A-V.vW"
}, :as => :creator)
  
julian.admin = false
julian.staff = true
julian.save

julian.grants.create({
  client_id: wackadoo_client.id,
  scopes:    wackadoo_client.scopes,
});
