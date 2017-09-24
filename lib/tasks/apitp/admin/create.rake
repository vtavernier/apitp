require 'securerandom'

namespace :apitp do
  namespace :admin do
    desc "Create the admin user with specified name and e-mail, and generates a random password"
    task :create, [:name, :email] => [:environment] do |_t, args|
      pw = SecureRandom.base64(16)
      admin = AdminUser.create!(name: args[:name],
                                email: args[:email],
                                password: pw)
      puts "Created #{admin.name_email} (password: << #{pw} >>)"
    end
  end
end