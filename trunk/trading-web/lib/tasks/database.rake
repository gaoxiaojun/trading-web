namespace :db do
  namespace :test do

    desc 'Prepare the test database and migrate schema'
    redefine_task :prepare => :environment do
      Rake::Task['db:test:migrate_schema'].invoke
    end

    desc 'Use the migrations to create the test database'
    task :migrate_schema => 'db:test:purge' do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Migrator.migrate("db/migrate/")
    end
  
  end
end

desc "Drop then recreate the dev database, migrate up, and load fixtures" 
task :remigrate => :environment do
  return unless %w[development test staging].include? RAILS_ENV
  ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.drop_table t }
  Rake::Task[:migrate].invoke
end