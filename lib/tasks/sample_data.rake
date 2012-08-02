require 'faker'

namespace :db do
  desc "Fill database with development users"
  task :populate => :environment do
    
    wackadoo_client = Client.find_by_identifier("WACKADOOHTML5")
                        
    egbert = Identity.new({
      :nickname              => "Egbert",
      :surname               => "Lange",
      :firstname             => "Sascha",
      :email                 => "sascha77@googlemail.com",
      :password              => "sonnen",
      :password_confirmation => "sonnen"
    }, :as => :creator)
    
    egbert.admin = true
    egbert.staff = true
    egbert.save

    egbert.grants.create({
      client_id: wackadoo_client.id,
      scopes:    wackadoo_client.scopes,
    })
    
                    
    paffi = Identity.new({
      :nickname              => "paffi",
      :surname               => "Fox",
      :firstname             => "Patrick",
      :email                 => "p@trick-fox.de",
      :password              => "ploppp",
      :password_confirmation => "ploppp"
    }, :as => :creator)
                              
    paffi.admin = true
    paffi.staff = true
    paffi.save
    
    paffi.grants.create({
      client_id: wackadoo_client.id,
      scopes:    wackadoo_client.scopes,
    })
    
    
    julian = Identity.new({
      :nickname              => "Julian",
      :surname               => "Schmid",
      :firstname             => "Julian",
      :email                 => "schmidj@informatik.uni-freiburg.de",
      :password              => "asdfasdf",
      :password_confirmation => "asdfasdf"
    }, :as => :creator)
    
    julian.admin = true
    julian.staff = true
    julian.save

    julian.grants.create({
      client_id: wackadoo_client.id,
      scopes:    wackadoo_client.scopes,
    })

    max = Identity.new({
      :nickname              => "max",
      :surname               => "Buck",
      :firstname             => "Max",
      :email                 => "max@5dlab.com",
      :password              => "123456",
      :password_confirmation => "123456"
    }, :as => :creator)
    
    max.admin = true
    max.staff = true
    max.save

    max.grants.create({
      client_id: wackadoo_client.id,
      scopes:    wackadoo_client.scopes,
    })

  end

  desc "Fill database with additonal sample users"
  task :populate_fake => :environment do
    
    wackadoo_client = Client.find_by_identifier("WACKADOOHTML5")
                        
    999.times do |n|
      firstname = Faker::Name.first_name
      surname   = Faker::Name.last_name
      name      = "#{firstname} #{surname}"
      password = "password"
      name_number = rand(20)
      identity = Identity.create({
        :nickname              => ((1..3).include?(name_number) ? "" : Faker::Internet.user_name(name)),
        :firstname             => ((1..2).include?(name_number) ? "" : firstname),
        :surname               => (name_number == 1 ? "" : surname),
        :email                 => Faker::Internet.email(name),
        :password              => password,
        :password_confirmation => password
      }, :as => :creator)
      identity.admin = rand(30) == 1   # create a few random staff and admin members.
      identity.staff = rand(10) == 1   # note: for most admins, "staff=true" will not be set!
      identity.save
      
      identity.grants.create({
        client_id: wackadoo_client.id,
        scopes:    wackadoo_client.scopes,
      })
    end
  end  
end