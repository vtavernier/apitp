namespace :apitp do
  namespace :admin do
    namespace :super do
      desc "Unsets an administrative account super user status"
      task :unset, [:email] => [:environment] do |_t, args|
        begin
          admin = AdminUser.find_by_email(args[:email])

          unless admin.super_admin?
            puts "The requested user (#{admin.name_email}) is not a super user."
          else
            admin.super_admin = false
            if admin.save
              puts "#{admin.name_email} is now a normal admin."
            else
              puts "Failed to set #{admin.name_email} as a normal admin."
            end
          end
        rescue ActiveRecord::RecordNotFound
          puts "The requested user (#{args[:email]}) was not found."
        end
      end
    end
  end
end