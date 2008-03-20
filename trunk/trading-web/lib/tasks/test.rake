desc 'Use migrations to create a test database for testing in ide'
task :test_remigrate do
  ENV['RAILS_ENV'] ||= 'test'
  Rake::Task[:remigrate].invoke
  Rake::Task['db:fixtures:load'].invoke
end

desc 'Run a single test'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

#  rake test                           # run tests normally
#  rake test TEST=/test/unit/just_one_file.rb     # run just one test file.
#  rake test TESTOPTS="-v"             # run in verbose mode
#  rake test TESTOPTS="--runner=fox"   # use the fox test runner

