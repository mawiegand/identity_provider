require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    identity = Identity.create(:name => "Sascha Lange",
                               :email => "sascha77@googlemail.com",
                               :password => "sonnen",
                               :password_confirmation => "sonnen")
    identity.admin = true
    identity.staff = true
    identity.save
                    
    999.times do |n|
      name = Faker::Name.name
      email = "example.#{n}@wackadu.de"
      password = "password"
      identity = Identity.create(:name => name,
                                 :email => email,
                                 :password => password,
                                 :passward_confirmation => password)
      identity.admin = rand(10) == 1
      identity.staff = rand(6) == 1
      identity.save
    end
  end
end