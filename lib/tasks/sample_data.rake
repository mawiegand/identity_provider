require 'faker'

namespace :db do
  desc "Fill database with additonal sample users"
  task :add_fake_accounts => :environment do
    
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
      });
    end
  end  
end