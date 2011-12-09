require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    Identity.create(:name => "Sascha Lange",
                    :email => "sascha77@googlemail.com",
                    :password => "sonnen",
                    :password_confirmation => "sonnen")
    999.times do |n|
      name = Faker::Name.name
      email = "example.#{n}@wackadu.de"
      password = "password"
      Identity.create(:name => name,
                      :email => email,
                      :password => password,
                      :passward_confirmation => password)
    end
  end
end