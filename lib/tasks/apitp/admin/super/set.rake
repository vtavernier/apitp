namespace :apitp do
  namespace :admin do
    namespace :super do
      desc "Sets an administrative account as super user"
      task :set, [:email] => [:environment] do |_t, args|
        begin
          admin = AdminUser.find_by_email(args[:email])

          if admin.super_admin?
            puts "The requested user (#{admin.name_email}) is already a super user."
          else
            admin.super_admin = true
            if admin.save
              puts "#{admin.name_email} is now a super user."
            else
              puts "Failed to set #{admin.name_email} as a super user."
            end
          end
        rescue ActiveRecord::RecordNotFound
          puts "The requested user (#{args[:email]}) was not found."
        end
      end
    end
  end
end