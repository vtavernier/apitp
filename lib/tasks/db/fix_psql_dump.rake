namespace :db do
  desc "Fix 'ERROR:  must be owner of extension plpgsql' complaints from Postgresql"
  task :fix_psql_dump do |task|
    filename = ENV['DB_STRUCTURE'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, "structure.sql")
    sql = File.read(filename)
    sql.sub!(/(CREATE EXTENSION IF NOT EXISTS plpgsql)/, '-- \1')
    sql.sub!(/(COMMENT ON EXTENSION plpgsql)/, '-- \1')
    File.open(filename, 'w') do |f|
      f.write(sql)
    end
    task.reenable
  end
end

Rake::Task["db:structure:dump"].enhance do
  Rake::Task["db:fix_psql_dump"].invoke
end
