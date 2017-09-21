# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
  admin =
      begin
        AdminUser.find_by_email!('admin@example.com')
      rescue ActiveRecord::RecordNotFound
        AdminUser.create!(name: 'Development Admin',
                          email: 'admin@example.com',
                          password: 'password',
                          password_confirmation: 'password')
      end

  even_group =
    begin
      Group.find_by_name!('Even group')
    rescue ActiveRecord::RecordNotFound
      Group.create!(year: Date.today.year,
                    name: 'Even group',
                    admin: admin)
    end

  odd_group =
    begin
      Group.find_by_name!('Odd group')
    rescue ActiveRecord::RecordNotFound
      Group.create!(year: Date.today.year,
                    name: 'Odd group',
                    admin: admin)
    end

  N_CURRENT = User.count
  N_USERS = 5

  (N_CURRENT + 1).upto(N_USERS + N_CURRENT) do |i|
    user =
        User.create!(name: "User #{i}",
                     email: "user#{i}@example.com",
                     password: 'password',
                     password_confirmation: 'password')

    if i % 2 == 0
      even_group.users << user
    else
      odd_group.users << user
    end
  end
end
