# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


client = Client.create({
                          :identifier   => "XYZ",
                          :scopes       => "5dentity wackadoo",
                          :grant_types  => "password"
}, :as => :creator)

client = Client.create({
                          :identifier   => "Payment",
                          :scopes       => "5dentity payment",
                          :password     => "wacky",
                          :grant_types  => "password"
}, :as => :creator)

client = Client.create({
                          :identifier   => "WACKADOOHTML5",
                          :scopes       => "5dentity wackadoo payment",
                          :password     => "wacky",
                          :grant_types  => "password"
}, :as => :creator)

client = Client.create({
                          :identifier   => "HeldenDuell",
                          :scopes       => "5dentity heldenduell",
                          :grant_types  => "password"
}, :as => :creator)

identity = Identity.new({ :nickname  => "Sascha",
                          :surname   => "Lange",
                          :firstname => "Sascha",
                          :email     => "sascha@5dlab.com",
                          :password  => "1.A-V.vW",
                          :password_confirmation => "sonnen"}, :as => :creator)
identity.admin = true
identity.staff = true
identity.save
                
identity = Identity.new({ :nickname  => "Patrick",
                          :surname   => "Fox",
                          :firstname => "Patrick",
                          :email     => "patrick@5dlab.com",
                          :password  => "1.A-V.vW",
                          :password_confirmation => "ploppp"}, :as => :creator)
identity.admin = true
identity.staff = true
identity.save


identity = Identity.new({ :nickname  => "Hajo",
                          :surname   => "Runne",
                          :firstname => "Hajo",
                          :email     => "hajo@5dlab.com",
                          :password  => "1.A-V.vW",
                          :password_confirmation => "ploppp"}, :as => :creator)
identity.admin = true
identity.staff = true
identity.save


identity = Identity.new({ :nickname  => "Max",
                          :surname   => "Buck",
                          :firstname => "Max",
                          :email     => "max@5dlab.com",
                          :password  => "1.A-V.vW",
                          :password_confirmation => "ploppp"}, :as => :creator)
identity.admin = true
identity.staff = true
identity.save


identity = Identity.new({ :nickname  => "Julian",
                          :surname   => "Schmid",
                          :firstname => "Julian",
                          :email     => "julian@5dlab.com",
                          :password  => "1.A-V.vW",
                          :password_confirmation => "asdfasdf"}, :as => :creator)
identity.admin = true
identity.staff = false
identity.save
