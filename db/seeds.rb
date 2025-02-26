# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(name: "Example User", email: "example@railstutorial.org", 
                                    password: "foobar", password_confirmation: "foobar", admin: true,
                                    activated: true, activated_at: Time.zone.now)

#a bunch of other fake users
99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    User.create!(name: name, email: email, password: password, password_confirmation: password,
                                            activated: true, activated_at: Time.zone.now)
end

#a bunch of fake microposts
users = User.order(:created_at).take(6)         #grab the first 6 created users
50.times do
    content = Faker::Lorem.sentence(word_count: 5)
    users.each { |user| user.microposts.create!(content: content)}
end

#creating following relationships
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each{ |followed| user.follow(followed)}           #user follows users 2-50
followers.each{ |follower| follower.follow(user)}            #user is followed by users 3-40