namespace :apitp do
  namespace :db do
    desc "Clears the website database except for the administrator accounts"
    task :clear => :environment do
      ActiveRecord::Base.transaction do
        # destroy_all to delete the files as well
        Submission.destroy_all
        # delete_all is fine, in a transaction
        Assignment.delete_all
        TeamMembership.delete_all
        Team.delete_all
        Project.delete_all
        GroupMembership.delete_all
        Group.delete_all
        User.delete_all
      end
    end
  end
end
