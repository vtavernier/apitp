namespace :apitp do
  namespace :email do
    desc "Processes the pending emails immediately"
    task :process => :environment do
      ProcessPendingEmailsJob.perform_now
    end
  end
end