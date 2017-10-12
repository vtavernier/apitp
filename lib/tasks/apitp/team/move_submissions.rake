namespace :apitp do
  namespace :team do
    desc "Moves the submissions to the respective teams"
    task :move_submissions => :environment do
      MoveSubmissionsJob.perform_now(nil)
    end
  end
end