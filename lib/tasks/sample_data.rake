require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    identity = Identity.create(:nickname  => "Egbert",
                               :surname   => "Lange",
                               :firstname => "Sascha",
                               :email     => "sascha77@googlemail.com",
                               :password  => "sonnen",
                               :password_confirmation => "sonnen")
    identity.admin = true
    identity.staff = true
    identity.save
                    
    999.times do |n|
      firstname = Faker::Name.first_name
      surname   = Faker::Name.last_name
      name      = "#{firstname} #{surname}"
      password = "password"
      identity = Identity.create(:nickname  => Faker::Internet.user_name(name),
                                 :firstname => firstname,
                                 :surname   => surname,
                                 :email     => Faker::Internet.email(name),
                                 :password  => password,
                                 :passward_confirmation => password)
      identity.admin = rand(30) == 1   # create a few random staff and admin members.
      identity.staff = rand(10) == 1   # note: for most admins, "staff=true" will not be set!
      identity.save
    end
  end
end