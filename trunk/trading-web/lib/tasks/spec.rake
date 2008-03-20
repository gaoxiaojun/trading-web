require 'rake'
require 'vendor/plugins/rspec/lib/spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('example_specs') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

desc "Generate specdocs for examples for inclusion in RDoc"
Spec::Rake::SpecTask.new('examples_specdoc') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ["--format", "specdoc"]
  t.out = 'doc/SPEC_EXAMPLES.txt'
end

desc "Generate HTML report for failing examples"
Spec::Rake::SpecTask.new('examples_specdoc_with_html') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ["--format", "html", "--diff"]
  t.out = 'doc/output/spec_examples.html'
  t.fail_on_error = false
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.out = 'doc/output/coverage'
  t.rcov = true
end

#RCov::VerifyTask.new(:verify_rcov => :spec) do |t|
#  t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
#  t.index_html = 'doc/output/coverage/index.html'
#end