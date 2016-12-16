require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Dir.glob("benchmarks/*.rake").each do |file|
  import file
end

desc "Run benchmarks"
task :benchmark => ["benchmarks:deflate"]
