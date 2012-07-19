require 'faker'

namespace :db do
  desc "Fill database with sample data"
    
  task :populate => :environment do
    
    Rake::Task['db:reset'].invoke
    
    Client.create({
                                :identifier   => "XYZ",
                                :scopes       => "5dentity wackadoo",
                                :grant_types  => "password",
    }, :as => :creator)
    
    
    Client.create({
                                :identifier   => "Payment",
                                :scopes       => "5dentity payment",
                                :password     => "wacky",
                                :grant_types  => "password",
    }, :as => :creator)
    
    clientwack = Client.create({
                                :identifier   => "WACKADOOHTML5",
                                :scopes       => "5dentity wackadoo payment",
                                :password     => "wacky",
                                :grant_types  => "password",
    }, :as => :creator)
    
    identity = Identity.new({:nickname  => "Egbert",
                                :surname   => "Lange",
                                :firstname => "Sascha",
                                :email     => "sascha77@googlemail.com",
                                :password  => "sonnen",
                                :password_confirmation => "sonnen"}, :as => :creator)
    identity.admin = true
    identity.staff = true
    identity.save
identity.grants.create({
  client_id: clientwack.id,
  scopes: clientwack.scopes,
});
                    
    identity = Identity.new({:nickname  => "paffi",
                                :surname   => "Fox",
                                :firstname => "Patrick",
                                :email     => "p@trick-fox.de",
                                :password  => "ploppp",
                                :password_confirmation => "ploppp"}, :as => :creator)
    identity.admin = true
    identity.staff = true
    identity.save
identity.grants.create({
  client_id: clientwack.id,
  scopes: clientwack.scopes,
});
                    
    999.times do |n|
      firstname = Faker::Name.first_name
      surname   = Faker::Name.last_name
      name      = "#{firstname} #{surname}"
      password = "password"
      name_number = rand(20)
      identity = Identity.create({:nickname  => ((1..3).include?(name_number) ? "" : Faker::Internet.user_name(name)),
                                  :firstname => ((1..2).include?(name_number) ? "" : firstname),
                                  :surname   => (name_number == 1    ? "" : surname),
                                  :email     => Faker::Internet.email(name),
                                  :password  => password,
                                  :password_confirmation => password}, :as => :creator)
      identity.admin = rand(30) == 1   # create a few random staff and admin members.
      identity.staff = rand(10) == 1   # note: for most admins, "staff=true" will not be set!
      identity.save
    end
  end
  
  desc "Fill database with sample data"
  task :populate_admin_only => :environment do
    
    Rake::Task['db:reset'].invoke
    
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
    
    clientwack = Client.create({
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
    
    identity = Identity.new({ :nickname  => "Egbert",
                              :surname   => "Lange",
                              :firstname => "Sascha",
                              :email     => "sascha77@googlemail.com",
                              :password  => "sonnen",
                              :password_confirmation => "sonnen"}, :as => :creator)
    identity.admin = true
    identity.staff = true
    identity.save
identity.grants.create({
  client_id: clientwack.id,
  scopes: clientwack.scopes,
});
                    
    identity = Identity.new({ :nickname  => "paffi",
                              :surname   => "Fox",
                              :firstname => "Patrick",
                              :email     => "p@trick-fox.de",
                              :password  => "ploppp",
                              :password_confirmation => "ploppp"}, :as => :creator)
    identity.admin = true
    identity.staff = true
    identity.save
identity.grants.create({
  client_id: clientwack.id,
  scopes: clientwack.scopes,
});
    
    
    identity = Identity.new({ :nickname  => "Julian",
                              :surname   => "Schmid",
                              :firstname => "Julian",
                              :email     => "schmidj@informatik.uni-freiburg.de",
                              :password  => "asdfasdf",
                              :password_confirmation => "asdfasdf"}, :as => :creator)
    identity.admin = true
    identity.staff = true
    identity.save
identity.grants.create({
  client_id: clientwack.id,
  scopes: clientwack.scopes,
});
    
  end
  
end